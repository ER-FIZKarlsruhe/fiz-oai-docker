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


## 1. Tear down the stack and backup es-data

```bash
docker stack rm oai
# wait for all oai_* containers to actually exit
watch docker service ls
```

Once the services are gone, move the ES7 data directory aside on every node that held
it — don't delete it!

```bash
sudo mv "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai/es-data" \
   "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai/es-data.es7.bak"
sudo mkdir -p "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai/es-data"
sudo chown elasticseach:elasticsearch "$OAI_INSTALL_DIRECTORY_ENV/data/elasticsearch_oai/es-data"
```

## 2. Update docker-compose and init-fizoai-database.sh

- Download the latest versions of docker-compose to  $OAI_INSTALL_DIRECTORY_ENV

https://github.com/ER-FIZKarlsruhe/fiz-oai-docker/blob/ES9/docker-compose-with-cassandra.yml

- Download the latest versions of init-fizoai-elasticsearch.sh to  ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/init-fizoai-elasticsearch.sh

https://github.com/ER-FIZKarlsruhe/fiz-oai-docker/blob/ES9/configs/elasticsearch_oai/init-fizoai-elasticsearch.sh


## 3. Update configuration files

| File | Change |
|---|---|
| `configs/elasticsearch_oai/oai-elasticsearch.yml` | adds `xpack.security.enabled: false` — ES8+ turns on auth and self-signed TLS by default; nothing here speaks HTTPS or sends credentials |
| `configs/elasticsearch_oai/item_mapping_es` | same mapping content, renamed from `item_mapping_es_v7` — host and container path now match |

> **Don't skip:** if `xpack.security.enabled` is left at its ES9 default (on), the setup
> container's plain-HTTP `curl` calls and the backend's unauthenticated client will both
> fail closed against the new cluster.

## 4. Update /etc/environment
```bash
OAI_ELASTICSEARCH_VERSION_ENV=9.5.2
OAI_BACKEND_VERSION_ENV=1.7.0
OAI_FRONTEND_VERSION_ENV=1.7.0
```

## 5. Deploy the fresh stack

```bash
set -a; . /etc/environment; set +a
docker stack deploy -c docker-compose4swarm.yml oai
```


## 6. Verify the ES9 bootstrap

The `elasticsearch-oai-setup` service from docker-compose runs automatically against the empty data directory and
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
