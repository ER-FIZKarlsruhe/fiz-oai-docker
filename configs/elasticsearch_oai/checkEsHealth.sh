#!/bin/bash

URL="http://localhost:9200/_cluster/health?wait_for_status=green&timeout=1s"

response=$(curl --write-out %{http_code} --silent --output /dev/null $URL)
if [[ "$response" -eq 200 ]]; then
  echo "Elasticsearch Status is GREEN"
  exit 0
else
  echo "Waiting for Elasticsearch Status GREEN"
  exit 1
fi
