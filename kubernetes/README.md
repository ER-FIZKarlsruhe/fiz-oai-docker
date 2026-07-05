# fiz-oai on Kubernetes

Kubernetes port of [`docker-compose-with-cassandra.yml`](../docker-compose-with-cassandra.yml).
Everything lives in the `fiz-oai` namespace.

## What's here

| File | Compose equivalent |
|---|---|
| `namespace.yaml` | - |
| `secrets.yaml` | credentials embedded in `configs/.env`, `configs/cassandra/jmxremote.password`, `configs/oai_backend/fiz-oai-backend.properties`, `configs/.cassandra_dump_env` |
| `configmap-*.yaml` | the non-secret files under `configs/` |
| `cassandra-statefulset.yaml` | `cassandra` + `cassandra-backup` services (run as two containers of one Pod so they can share the data volume) |
| `cassandra-init-job.yaml` | `cassandra-oai-setup` |
| `elasticsearch-statefulset.yaml` | `elasticsearch-oai` |
| `elasticsearch-init-job.yaml` | `elasticsearch-oai-setup` |
| `oai-backend.yaml` | `oai-backend` |
| `oai-provider.yaml` | `oai-provider` |
| `ingress.yaml` | the `8080`/`8081` port mappings, routed through ingress-nginx instead |

Cassandra and Elasticsearch are StatefulSets with `volumeClaimTemplates` (PVCs)
standing in for the compose bind mounts under `${OAI_INSTALL_DIRECTORY_ENV}/data`.
Both still run as a single node (`replication_factor: 1`, `discovery.type=single-node`),
matching the original compose setup - this is a lift-and-shift, not a
re-architecture into a multi-node cluster.

## Before applying

1. **Secrets** - edit `secrets.yaml` and replace every `CHANGE_ME`
   (Cassandra passwords, JMX password, the rendered
   `fiz-oai-backend.properties`, the backup mailer/cqlsh credentials). For a
   real cluster, manage this file with sealed-secrets / SOPS / an
   external-secrets operator instead of committing plaintext.
2. **Registry access** - `oai-backend`, `oai-provider` and `cassandra-backup`
   pull from `docker.dev.fiz-karlsruhe.de`. Create the referenced pull secret:
   ```
   kubectl create secret docker-registry fiz-registry-credentials \
     -n fiz-oai --docker-server=docker.dev.fiz-karlsruhe.de \
     --docker-username=... --docker-password=...
   ```
3. **Ingress controller** - these manifests target
   [ingress-nginx](https://kubernetes.github.io/ingress-nginx/):
   ```
   helm upgrade --install ingress-nginx ingress-nginx \
     --repo https://kubernetes.github.io/ingress-nginx \
     --namespace ingress-nginx --create-namespace
   ```
   Then set `spec.rules[0].host` in `ingress.yaml` to your real hostname (and
   uncomment/fill in `spec.tls` if you terminate TLS at the ingress).
4. **Storage** - the StatefulSets request a default `StorageClass`. Adjust
   `volumeClaimTemplates` storage sizes/`storageClassName` per environment.
5. **Privileged init container** - `elasticsearch-statefulset.yaml` includes
   an init container that sets `vm.max_map_count=262144` and needs privileged
   pods to be allowed. If your cluster forbids that, drop the init container
   and set `vm.max_map_count` on the nodes instead.

## Apply

```
kubectl apply -k kubernetes/
```

(or `kubectl apply -f kubernetes/<file>.yaml` one by one, in roughly the
order listed in `kustomization.yaml` - the setup Jobs need Cassandra/
Elasticsearch to be reachable, and `oai-backend`/`oai-provider` wait on their
dependencies via init containers either way).

## Notes / deliberate deviations from the compose file

- **Cassandra/Elasticsearch networking fields**: `cassandra.yaml`'s
  `listen_address`, `broadcast_address`, `broadcast_rpc_address` and
  `seed_provider.seeds` are still hardcoded to the original host's
  `10.0.1.33` inside the ConfigMap. They're overridden at container startup
  by the `CASSANDRA_*` env vars on the StatefulSet (the official cassandra
  image's entrypoint sed-patches them in), so nothing needs to be hand-edited
  in the 1800-line file.
- **`item_mapping_es_v7` mount path**: the compose file mounted it at
  `/item_mapping_es`, while `init-fizoai-elasticsearch.sh` referenced it by
  the relative filename `item_mapping_es_v7` - those never matched. The Job
  here mounts it at `/item_mapping_es_v7`, which is what the script actually
  needs.
- **`cassandra-oai-setup` no longer does a blind `sleep 20`** before running
  `cqlsh`; it retries against Cassandra until the CQL/auth service actually
  answers.
- **`oai-backend`/`oai-provider` `depends_on` conditions** become init
  containers that check the real precondition (keyspace exists / ES index
  exists / backend responds) instead of a compose-level health check.
