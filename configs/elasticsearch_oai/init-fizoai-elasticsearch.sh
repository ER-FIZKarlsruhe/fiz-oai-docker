#!/bin/sh
status_code=$(curl -L --write-out %{http_code} --noproxy '*' --silent --output /dev/null http://elasticsearch-oai:9200/items/_search)
if [[ "$status_code" -ne 404 ]] ; then
  echo "Skip Index-Mappings creation"
  exit 0
fi
curl -v -L --noproxy '*' -X PUT -H 'Content-Type: application/json' --data "@item_mapping_es" -i 'http://elasticsearch-oai:9200/items'
exit 0

