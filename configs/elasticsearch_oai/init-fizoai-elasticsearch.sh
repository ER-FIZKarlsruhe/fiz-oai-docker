#!/bin/sh

URL="http://elasticsearch-oai:9200/_cluster/health?wait_for_status=green&timeout=1s"
MAX_WAIT=240
i=0

#Wait for Elasticsearch Health-Status green (returns status-code 200) for MAX_WAIT Seconds
while [ $i -le $MAX_WAIT ]; do
  response=$(curl -L --noproxy '*' --write-out %{http_code} --silent --output /dev/null $URL)
  if [[ "$response" -eq 200 ]]; then
    break;
  fi
  i=$((i + 1))
done

#Check if index-mappings already exist. Otherwise create them.
status_code=$(curl -L --write-out %{http_code} --noproxy '*' --silent --output /dev/null http://elasticsearch-oai:9200/items/_search)
if [[ "$status_code" -ne 404 ]] ; then
  echo "Skip Index-Mappings creation"
  exit 0
fi
curl -v -L --noproxy '*' -X PUT -H 'Content-Type: application/json' --data "@item_mapping_es" -i 'http://elasticsearch-oai:9200/items'
exit 0

