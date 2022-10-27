echo "Waiting for Elasticsearch fully initialized..."
status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:9200/_cluster/health?wait_for_status=green&timeout=120s)

if [[ "$status_code" -ne 200 ]] ; then
  echo "Site status changed to $status_code"
else
  curl -v -X PUT -H 'Content-Type: application/json' --data "@item_mapping_es_v7" -i 'http://elasticsearch-oai:9200/items'
  exit 0
fi

