#!/bin/bash

#Check if Elasticsearch Health-Status is green (returns status-code 200)
URL_GREEN="http://elasticsearch-oai:9200/_cluster/health?wait_for_status=green&timeout=1s"
URL_YELLOW="http://elasticsearch-oai:9200/_cluster/health?wait_for_status=yellow&timeout=1s"

response_green=$(curl -L --noproxy '*' --write-out %{http_code} --silent --output /dev/null $URL_GREEN)
if [[ "$response_green" -eq 200 ]]; then
  echo "Elasticsearch Status is GREEN"
  exit 0
else
  response_yellow=$(curl -L --noproxy '*' --write-out %{http_code} --silent --output /dev/null $URL_YELLOW)
  if [[ "$response_yellow" -eq 200 ]]; then
    echo "Elasticsearch Status is YELLOW"
    exit 0
  fi
  echo "Waiting for Elasticsearch Status GREEN"
  exit 1
fi

