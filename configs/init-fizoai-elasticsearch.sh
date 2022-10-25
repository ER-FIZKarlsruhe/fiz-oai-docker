echo "Waiting for Elasticsearch fully initialized..."
sleep 40

curl -v -X PUT -H 'Content-Type: application/json' --data "@item_mapping_es_v7" -i 'http://elasticsearch-oai:9200/items'

