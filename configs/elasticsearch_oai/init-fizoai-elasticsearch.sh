#!/bin/sh

URL_GREEN="http://elasticsearch-oai:9200/_cluster/health?wait_for_status=green&timeout=1s"
URL_YELLOW="http://elasticsearch-oai:9200/_cluster/health?wait_for_status=yellow&timeout=1s"

MAX_WAIT=240
i=0

#Wait for Elasticsearch Health-Status green (returns status-code 200) for MAX_WAIT Seconds
while [ $i -le $MAX_WAIT ]; do
  echo "Check ES-Status"
  response=$(curl -L --noproxy '*' --write-out %{http_code} --silent --output /dev/null $URL_GREEN)
  if [[ "$response" -eq 200 ]]; then
    echo "Elasticsearch Status is GREEN"
    break;
  fi
  response=$(curl -L --noproxy '*' --write-out %{http_code} --silent --output /dev/null $URL_YELLOW)
  if [[ "$response" -eq 200 ]]; then
    echo "Elasticsearch Status is YELLOW"
    break;
  fi
  echo "Elasticsearch Status is not GREEN or YELLOW"
  sleep 1
  i=$((i + 1))
done

#Check if index-mappings already exist. Otherwise create them.
status_code=$(curl -L --write-out %{http_code} --noproxy '*' --silent --output /dev/null http://elasticsearch-oai:9200/items/_search)
if [[ "$status_code" -ne 404 ]] ; then
  echo "Skip Index-Mappings creation"
  exit 0
fi
curl -v -L --noproxy '*' -X PUT -H 'Content-Type: application/json' --data "@item_mapping_es" -i 'http://elasticsearch-oai:9200/items1'
curl -v -L --noproxy '*' -X PUT -H 'Content-Type: application/json' -i 'http://elasticsearch-oai:9200/items1/_alias/items'
curl -v -L --noproxy '*' -X PUT -H 'Content-Type: application/json' --data '{"type":"fs","settings":{"location":"/usr/share/elasticsearch/backup","compress":true}}' -i 'http://elasticsearch-oai:9200/_snapshot/oai-backup'
curl -v -L --noproxy '*' -X PUT -H 'Content-Type: application/json' --data '{"schedule": "0 30 1 * * ?","name": "<daily-snapshot-{now/d}>","repository": "oai-backup","config": {"indices": "*","include_global_state": true},"retention": {"expire_after": "30d","min_count": 5,"max_count": 10}}' -i 'http://elasticsearch-oai:9200/_slm/policy/daily-snapshot'
curl -v -L --noproxy '*' -X PUT -H 'Content-Type: application/json' --data '{"schedule": "0 30 0 ? * SUN","name": "<weekly-snapshot-{now/d}>","repository": "oai-backup","config": {"indices": "*","include_global_state": true},"retention": {"expire_after": "90d","min_count": 5,"max_count": 10}}' -i 'http://elasticsearch-oai:9200/_slm/policy/weekly-snapshot'

exit 0

