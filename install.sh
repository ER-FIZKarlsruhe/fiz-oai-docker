INSTALL_DIR=/data/fiz-oai-eng-d-vm08/fiz-oai/

rm -rf ${INSTALL_DIR}

mkdir -p ${INSTALL_DIR}/configs/cassandra/
mkdir -p ${INSTALL_DIR}/data/cassandra/

mkdir -p ${INSTALL_DIR}/configs/elasticsearch_oai/
mkdir -p ${INSTALL_DIR}/data/elasticsearch_oai/
mkdir -p ${INSTALL_DIR}/logs/elasticsearch_oai/

mkdir -p ${INSTALL_DIR}/configs/oai_backend/
mkdir -p ${INSTALL_DIR}/data/oai_backend/
mkdir -p ${INSTALL_DIR}/logs/oai_backend/

mkdir -p ${INSTALL_DIR}/configs/oai_provider/
mkdir -p ${INSTALL_DIR}/data/oai_provider/
mkdir -p ${INSTALL_DIR}/logs/oai_provider/

cp ./configs/cassandra.yaml ${INSTALL_DIR}/configs/cassandra/
cp ./configs/cassandra-env.sh ${INSTALL_DIR}/configs/cassandra/
cp ./configs/init-fizoai-database.sh ${INSTALL_DIR}/configs/cassandra/

cp ./configs/oai-elasticsearch.yml ${INSTALL_DIR}/configs/elasticsearch_oai/

cp ./configs/fiz-oai-backend.properties ${INSTALL_DIR}/configs/oai_backend/

cp ./configs/oaicat.properties ${INSTALL_DIR}/configs/oai_provider/

cp docker-compose.yml ${INSTALL_DIR}
cp ./configs/.env ${INSTALL_DIR}
