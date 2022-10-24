INSTALL_DIR=/data/fiz-oai-eng-d-vm08/fiz-oai/

rm -rf ${INSTALL_DIR}

mkdir -p ${INSTALL_DIR}/configs/cassandra/
mkdir -p ${INSTALL_DIR}/data/cassandra/

mkdir -p ${INSTALL_DIR}/configs/elasticsearch_oai/
mkdir -p ${INSTALL_DIR}/data/elasticsearch_oai/

cp ./configs/cassandra.yaml ${INSTALL_DIR}/configs/cassandra/
cp ./configs/cassandra-env.sh ${INSTALL_DIR}/configs/cassandra/

cp ./configs/oai-elasticsearch.yml ${INSTALL_DIR}/configs/elasticsearch_oai/

cp docker-compose.yml ${INSTALL_DIR}
cp ./configs/.env ${INSTALL_DIR}
