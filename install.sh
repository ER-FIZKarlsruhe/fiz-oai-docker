INSTALL_DIR=/data/fiz-oai-eng-d-vm08/fiz-oai/

rm -rf ${INSTALL_DIR}

###############################################################################
# Init Cassandra. The container runs under the user_id 999
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/cassandra/
mkdir -p ${INSTALL_DIR}/data/cassandra/

cp ./configs/cassandra.yaml ${INSTALL_DIR}/configs/cassandra/
cp ./configs/cassandra-env.sh ${INSTALL_DIR}/configs/cassandra/
cp ./configs/init-fizoai-database.sh ${INSTALL_DIR}/configs/cassandra/

chown -R 999:999 ${INSTALL_DIR}/data/
chown -R 999:999 ${INSTALL_DIR}/configs/

###############################################################################
# Init Elasticsearch. The container runs under the user_id 1000
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/elasticsearch_oai/
mkdir -p ${INSTALL_DIR}/data/elasticsearch_oai/es-data/
mkdir -p ${INSTALL_DIR}/data/elasticsearch_escidocng/backup/
mkdir -p ${INSTALL_DIR}/logs/elasticsearch_oai/

cp ./configs/oai-elasticsearch.yml ${INSTALL_DIR}/configs/elasticsearch_oai/
cp ./configs/item_mapping_es_v7 /configs/elasticsearch_oai/

chown -R 1000:1000 ${INSTALL_DIR}/data/elasticsearch_oai/
chown -R 1000:1000 ${INSTALL_DIR}/configs/elasticsearch_oai/
chown -R 1000:1000 ${INSTALL_DIR}/logs/elasticsearch_oai/

###############################################################################
# Init oai_backend. The container runs under the user_id 1000
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/oai_backend/
mkdir -p ${INSTALL_DIR}/data/oai_backend/
mkdir -p ${INSTALL_DIR}/logs/oai_backend/

cp ./configs/fiz-oai-backend.properties ${INSTALL_DIR}/configs/oai_backend/

###############################################################################
# Init oai_backend. The container runs under the user_id 1000
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/oai_provider/
mkdir -p ${INSTALL_DIR}/data/oai_provider/
mkdir -p ${INSTALL_DIR}/logs/oai_provider/

cp ./configs/oaicat.properties ${INSTALL_DIR}/configs/oai_provider/

###############################################################################
# Init docker-compose. The container runs under the user_id 1000
###############################################################################

cp docker-compose.yml ${INSTALL_DIR}
cp ./configs/.env ${INSTALL_DIR}
