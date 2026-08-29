# ES7 → ES9 Swarm Cutover

Migration guide for productive FIZ-OAI instances running Elasticsearch 7, deployed via
`docker-compose4swarm.yml`. Elasticsearch is a derived search index here — Cassandra
stays the system of record throughout, which is what makes this safe.

**Scope:** `docker-compose4swarm.yml` (Docker Swarm). Target: Elasticsearch 9.5.2.
Expected downtime: search/OAI-PMH listing results only, during one maintenance window.

## Why this can't be an in-place upgrade

Elasticsearch refuses to open on-disk indices written by a version more than one major
behind — a 9.x node will not start against 7.x data files, full stop. There is no rolling
or side-by-side path from 7 straight to 9.

That's why the plan below is a rebuild, not an upgrade: retire the old data directory,
let a fresh 9.x cluster bootstrap an empty index, then repopulate it entirely from
Cassandra via `/reindex/start`. The ES7 data folder is kept only as a rollback artifact —
nothing in this plan reads it back.

## 1. Freeze & confirm prerequisites

- Pull the updated `fiz-oai-docker` repo (`configs/.env`, `oai-elasticsearch.yml`,
  `init-fizoai-elasticsearch.sh`, `item_mapping_es` already carry the ES9 changes) onto
  every node that has the bind-mounted config.
- Confirm an `oai-backend` image built against `elasticsearch-java 9.5.2` is pushed and
  reachable — the stack pulls whatever tag `OAI_BACKEND_VERSION_ENV` names.
- Announce the maintenance window to harvesters: OAI-PMH responses will look empty
  (though never error) between the fresh bootstrap and the end of the reindex.

> Cassandra is never stopped, moved, or backed up as part of this plan — it already has
> its own snapshot cronjob, and it's the only store this migration actually depends on
> for correctness.

## 2. Back up the ES7 data folder

Rollback insurance, not a source for the new index. On each node running the
`elasticsearch-oai` service, archive the bind-mounted data directory before it's
overwritten:

```bash
# run on the node(s) holding the ES data volume
tar -C "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai" \
    -czf "/data/backups/elasticsearch_oai_es7_$(date +%F).tar.gz" es-data backup
```

Copy both `es-data` (the live indices) and `backup` (the ES snapshot repository, if one
was configured) — keep them paired.

> **Won't help going forward:** any existing ES7 snapshots in the `oai-backup` repository
> are only restorable into an ES7 (or, after an intermediate hop, ES8) cluster — the same
> version-gap rule applies to snapshots as to raw data files. This backup exists purely
> so you can revert this node to ES7 if the cutover has to be aborted.

## 3. Tear down the stack

```bash
docker stack rm oai
# wait for all oai_* containers to actually exit
watch docker service ls
```

Once the services are gone, move the ES7 data directory aside on every node that held
it — don't delete it, the tarball from step 2 is the safety net but an untouched folder
is a faster one:

```bash
mv "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai/es-data" \
   "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai/es-data.es7.bak"
mkdir -p "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai/es-data"
```

## 4. Point the stack at ES9

Re-copy the updated config onto `$OAI_INSTALL_DIRECTORY_ENV` (the same files
`install.sh` places there), or re-run it. The values that matter for this cutover:

| File | Change |
|---|---|
| `configs/.env` | `OAI_ELASTICSEARCH_VERSION_ENV=9.5.2`, and `OAI_BACKEND_VERSION_ENV` pointed at the ES9-compatible backend build |
| `configs/elasticsearch_oai/oai-elasticsearch.yml` | adds `xpack.security.enabled: false` — ES8+ turns on auth and self-signed TLS by default; nothing here speaks HTTPS or sends credentials |
| `configs/elasticsearch_oai/item_mapping_es` | same mapping content, renamed from `item_mapping_es_v7` — host and container path now match |

> **Don't skip:** if `xpack.security.enabled` is left at its ES9 default (on), the setup
> container's plain-HTTP `curl` calls and the backend's unauthenticated client will both
> fail closed against the new cluster.

## 5. Deploy the fresh stack

```bash
set -a; . /etc/environment; set +a
docker stack deploy -c docker-compose4swarm.yml oai
```

Swarm's `depends_on` only orders container start, it doesn't gate on health the way
Compose's `condition: service_healthy` does — that's fine here, since
`init-fizoai-elasticsearch.sh` already polls ES's own health endpoint for up to 240s
before touching indices.

## 6. Verify the ES9 bootstrap

Yes — `elasticsearch-oai-setup` runs automatically against the empty data directory and
does exactly what you'd expect: waits for green/yellow health, then creates a fresh
`items1` index from the mapping file, aliases it to `items`, and registers the
`oai-backup` snapshot repository with its daily/weekly SLM policies.

```bash
docker service logs oai_elasticsearch-oai-setup --tail 100
curl -s "http://<node>:9200/_cat/aliases?v"
# expect: items -> items1
```

**Expected state:** alias `items` points to a new, empty `items1`. `oai-backend` and
`oai-provider` containers are running and pass their health checks — but searches and
OAI-PMH listings return nothing yet. That's expected until step 7 finishes.

## 7. Trigger the full reindex from Cassandra

```bash
curl -X POST "$OAI_EXTERNAL_BACKEND_URL/reindex/start"
```

Leave `indexName` off. With no target index named, the backend builds a brand-new,
correctly-versioned index on its own: it scans existing indices, finds `items1`, creates
`items2` from the bundled mapping resource, and streams every item out of Cassandra into
it in batches of 500 (parallelised per batch). When the last batch lands, it atomically
swaps the `items` alias from `items1` to `items2` and drops the now-empty `items1` — no
manual index bookkeeping required.

Poll progress with:

```bash
curl -s "$OAI_EXTERNAL_BACKEND_URL/reindex/status"
```

> **Timing:** runtime scales with item count and Cassandra read throughput, not with
> anything ES9-specific. Run this in the announced maintenance window, and prefer the
> quieter side of it — the batch loop shares CPU with everything else the backend is
> doing.

Needs to abort partway through? `POST $OAI_EXTERNAL_BACKEND_URL/reindex/stop` is safe to
use here: it stops after the in-flight batch, drops the half-built `items2`, and leaves
the original alias untouched.

## 8. Validate

Before letting harvesters back in for real:

- Compare `/reindex/status`'s indexed count against your known Cassandra item count.
- Spot-check a handful of known identifiers through `GetRecord` on the OAI-PMH endpoint,
  including at least one deleted record if `deletedRecord=persistent` is in effect.
- Confirm the `items` alias now resolves to `items2` and that `items1` is gone
  (`_cat/aliases`, `_cat/indices`).
- Watch `oai-backend` logs for any `Reindex fails for …` entries — the loop continues
  past individual item errors by default, so failures don't halt the run, but they also
  won't announce themselves otherwise.

## 9. If it goes wrong

Because the only thing this migration changes is the disposable search index, backing
out is a stack-level revert, not a data-recovery exercise:

1. `docker stack rm oai`
2. Restore the archived directory: `mv es-data.es7.bak es-data` (or unpack the step 2
   tarball if the node changed)
3. Revert `configs/.env` to the previous `OAI_ELASTICSEARCH_VERSION_ENV` and
   `OAI_BACKEND_VERSION_ENV`, and drop the `xpack.security.enabled` line if you want the
   config byte-identical to the pre-migration one
4. `docker stack deploy -c docker-compose4swarm.yml oai`

> **One-way once you drop it:** the old `items1` index is only deleted after a
> *successful* alias swap in step 7 — a failed or stopped run never touches it. If you've
> already moved past step 8 and confirmed the ES9 index is good, treat the ES7 backup as
> retired, not as something to fall back to.

## 10. Clean up

After a retention window you're comfortable with (a week of stable production traffic is
a reasonable bar), remove `es-data.es7.bak` from each node and archive the step 2
tarballs to cold storage rather than deleting them outright — they're small relative to
Cassandra and cost little to keep for audit purposes.
