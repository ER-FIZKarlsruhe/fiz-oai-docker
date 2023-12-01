#!/bin/bash

#Check if Elasticsearch Health-Status is green (returns status-code 200)
URL="http://elasticsearch-oai:9200/_cluster/health?wait_for_status=green&timeout=1s"

response=$(curl -L --noproxy '*' --write-out %{http_code} --silent --output /dev/null $URL)
if [[ "$response" -eq 200 ]]; then
  echo "Elasticsearch Status is GREEN"
  exit 0
else
  echo "Waiting for Elasticsearch Status GREEN"
  exit 1
fi

