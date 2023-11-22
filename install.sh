#INSTALL_DIR=/data/fiz-oai-eng-d-vm08/fiz-oai/

ADMIN_USERNAME=admin
OAI_BACKEND_GROUPID=8007
OAI_PROVIDER_GROUPID=8008
CASSANDRA_GROUPID=999
ELASTICSEARCH_GROUPID=1000
INSTALL_DIR=$1
CASSANDRA_SUPERUSER_PASSWORD=$2
CASSANDRA_PASSWORD=$3

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
  echo "FIZ-OAI provider will be installed to ${INSTALL_DIR}!"
else
  echo "Wrong install-parameters. Call"
  echo "./install.sh <INSTALLATION_PATH> <CASSANDRA_SUPERUSER_PASSWORD> <CASSANDRA_PASSWORD>"
  exit 22
fi

###########################################################################
# Add groups and users
###########################################################################
groupadd --gid ${OAI_BACKEND_GROUPID} oai_backend > /dev/null 2>&1
groupadd --gid ${OAI_PROVIDER_GROUPID} oai_provider > /dev/null 2>&1
groupadd --gid ${CASSANDRA_GROUPID} cassandra > /dev/null 2>&1
groupadd --gid ${ELASTICSEARCH_GROUPID} oai_elasticsearch > /dev/null 2>&1

useradd --uid ${OAI_BACKEND_GROUPID} oai_backend > /dev/null 2>&1
useradd --uid ${OAI_PROVIDER_GROUPID} oai_provider > /dev/null 2>&1
useradd --uid ${CASSANDRA_GROUPID} cassandra > /dev/null 2>&1
useradd --uid ${ELASTICSEARCH_GROUPID} oai_elasticsearch > /dev/null 2>&1

usermod -a -G ${OAI_BACKEND_GROUPID} oai_backend > /dev/null 2>&1
usermod -a -G ${OAI_PROVIDER_GROUPID} oai_provider > /dev/null 2>&1
usermod -a -G ${CASSANDRA_GROUPID} cassandra > /dev/null 2>&1
usermod -a -G ${ELASTICSEARCH_GROUPID} oai_elasticsearch > /dev/null 2>&1

usermod -a -G ${OAI_BACKEND_GROUPID} ${ADMIN_USERNAME} > /dev/null 2>&1
usermod -a -G ${OAI_PROVIDER_GROUPID} ${ADMIN_USERNAME} > /dev/null 2>&1
usermod -a -G ${CASSANDRA_GROUPID} ${ADMIN_USERNAME} > /dev/null 2>&1
usermod -a -G ${ELASTICSEARCH_GROUPID} ${ADMIN_USERNAME} > /dev/null 2>&1

###############################################################################
# Init Cassandra. The container runs under the user_id CASSANDRA_GROUPID
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/cassandra/
mkdir -p ${INSTALL_DIR}/data/cassandra/

cp ./configs/cassandra/cassandra.yaml ${INSTALL_DIR}/configs/cassandra/
cp ./configs/cassandra/cassandra-env.sh ${INSTALL_DIR}/configs/cassandra/
cp ./configs/cassandra/init-fizoai-database.sh ${INSTALL_DIR}/configs/cassandra/
cp ./configs/wait-for-it.sh ${INSTALL_DIR}/configs/cassandra/
cp ./configs/cassandra/jmxremote.access ${INSTALL_DIR}/configs/cassandra/
cp ./configs/cassandra/jmxremote.password ${INSTALL_DIR}/configs/cassandra/

chmod +x ${INSTALL_DIR}/configs/cassandra/wait-for-it.sh
chown -R ${CASSANDRA_GROUPID}:${CASSANDRA_GROUPID} ${INSTALL_DIR}/data/
chown -R ${CASSANDRA_GROUPID}:${CASSANDRA_GROUPID} ${INSTALL_DIR}/configs/

###############################################################################
# Init Cassandra Backup.
###############################################################################
mkdir -p ${INSTALL_DIR}/configs/cassandra-backup/
mkdir -p ${INSTALL_DIR}/data/cassandra-backup/
mkdir -p ${INSTALL_DIR}/logs/cassandra-backup/

cp ./configs/docker-env/.cassandra_dump_env ${INSTALL_DIR}

###############################################################################
# Init Elasticsearch. The container runs under the user_id ELASTICSEARCH_GROUPID
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/elasticsearch_oai/
mkdir -p ${INSTALL_DIR}/data/elasticsearch_oai/es-data/
mkdir -p ${INSTALL_DIR}/data/elasticsearch_escidocng/backup/
mkdir -p ${INSTALL_DIR}/logs/elasticsearch_oai/

cp ./configs/elasticsearch_oai/oai-elasticsearch.yml ${INSTALL_DIR}/configs/elasticsearch_oai/
cp ./configs/elasticsearch_oai/item_mapping_es_v* ${INSTALL_DIR}/configs/elasticsearch_oai/
cp ./configs/elasticsearch_oai/init-fizoai-elasticsearch.sh ${INSTALL_DIR}/configs/elasticsearch_oai/
cp ./configs/wait-for-it.sh ${INSTALL_DIR}/configs/elasticsearch_oai/
cp ./configs/elasticsearch_oai/checkEsHealth.sh ${INSTALL_DIR}/configs/elasticsearch_oai/
chmod +x ${INSTALL_DIR}/configs/elasticsearch_oai/wait-for-it.sh

chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${INSTALL_DIR}/data/elasticsearch_oai/
chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${INSTALL_DIR}/configs/elasticsearch_oai/
chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${INSTALL_DIR}/logs/elasticsearch_oai/

###############################################################################
# Init oai_backend. The container runs under the user_id ${OAI_BACKEND_GROUPID}
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/oai_backend/
mkdir -p ${INSTALL_DIR}/data/oai_backend/
mkdir -p ${INSTALL_DIR}/logs/oai_backend/

cp ./configs/oai_backend/fiz-oai-backend.properties ${INSTALL_DIR}/configs/oai_backend/

chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${INSTALL_DIR}/data/oai_backend/
chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${INSTALL_DIR}/configs/oai_backend/
chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${INSTALL_DIR}/logs/oai_backend/

###############################################################################
# Init oai_provider. The container runs under the user_id ${OAI_PROVIDER_GROUPID}
###############################################################################

mkdir -p ${INSTALL_DIR}/configs/oai_provider/
mkdir -p ${INSTALL_DIR}/data/oai_provider/
mkdir -p ${INSTALL_DIR}/logs/oai_provider/

cp ./configs/oai_provider/oaicat.properties ${INSTALL_DIR}/configs/oai_provider/

chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${INSTALL_DIR}/data/oai_provider/
chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${INSTALL_DIR}/configs/oai_provider/
chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${INSTALL_DIR}/logs/oai_provider/


###############################################################################
# Init docker-compose
###############################################################################

cp docker-compose.yml ${INSTALL_DIR}
cp ./configs/.env ${INSTALL_DIR}
echo "OAI_DATA_FOLDER=${INSTALL_DIR}" >> ${INSTALL_DIR}/.env

###############################################################################
# Replace @@CASSANDRA_PASSWORD@@
###############################################################################
sed -i "s/@@CASSANDRA_SUPERUSER_PASSWORD@@/${CASSANDRA_SUPERUSER_PASSWORD}/g" ${INSTALL_DIR}/configs/cassandra/init-fizoai-database.sh
sed -i "s/@@CASSANDRA_PASSWORD@@/${CASSANDRA_PASSWORD}/g" ${INSTALL_DIR}/configs/cassandra/init-fizoai-database.sh
sed -i "s/@@CASSANDRA_PASSWORD@@/${CASSANDRA_PASSWORD}/g" ${INSTALL_DIR}/configs/cassandra/jmxremote.password
sed -i "s/@@CASSANDRA_PASSWORD@@/${CASSANDRA_PASSWORD}/g" ${INSTALL_DIR}/configs/oai_backend/fiz-oai-backend.properties
