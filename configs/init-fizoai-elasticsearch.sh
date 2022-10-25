#############################################################
# Init ElasticSearch
#############################################################
echo "Waiting for Elasticsearch...";
sleep 40s;

curl -v -X PUT -H 'Content-Type: application/json' --data "@item_mapping_es_v7" -i 'http://elasticsearch-oai:9200/item'

