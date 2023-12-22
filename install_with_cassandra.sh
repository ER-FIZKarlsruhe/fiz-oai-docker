#Read .env and fill it in Variables
while read line || [ -n "$line" ]; do
  if [[ ! $line =~ [^[:space:]] ]] || [[ $line = \#* ]]; then
    continue
  fi
  IFS='=' read -r key value <<< ${line}
  eval ${key}=\${value}
done < "configs/.env"

echo "fiz-oai-docker will be installed to ${OAI_INSTALL_DIRECTORY_ENV}!"

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
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/data/cassandra/

cp ./configs/cassandra/cassandra.yaml ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/
cp ./configs/cassandra/cassandra-env.sh ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/
cp ./configs/cassandra/init-fizoai-database.sh ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/
cp ./configs/wait-for-it.sh ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/
cp ./configs/cassandra/jmxremote.access ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/
cp ./configs/cassandra/jmxremote.password ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/

###############################################################################
# Init Cassandra Backup.
###############################################################################
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra-backup/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/data/cassandra-backup/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/logs/cassandra-backup/

cp ./configs/docker-env/.cassandra_dump_env ${OAI_INSTALL_DIRECTORY_ENV}

###############################################################################
# Init Elasticsearch. The container runs under the user_id ELASTICSEARCH_GROUPID
###############################################################################
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/data/elasticsearch_oai/es-data/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/data/elasticsearch_oai/backup/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/logs/elasticsearch_oai/

cp ./configs/elasticsearch_oai/oai-elasticsearch.yml ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/
cp ./configs/elasticsearch_oai/item_mapping_es_v* ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/
cp ./configs/elasticsearch_oai/init-fizoai-elasticsearch.sh ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/
cp ./configs/wait-for-it.sh ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/
cp ./configs/elasticsearch_oai/checkEsHealth.sh ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/

###############################################################################
# Init oai_backend. The container runs under the user_id ${OAI_BACKEND_GROUPID}
###############################################################################
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/data/oai_backend/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/logs/oai_backend/

cp ./configs/oai_backend/fiz-oai-backend.properties ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/
cp ./configs/oai_backend/checkBackendHealth.sh ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/

###############################################################################
# Init oai_provider. The container runs under the user_id ${OAI_PROVIDER_GROUPID}
###############################################################################
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_provider/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/data/oai_provider/
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/logs/oai_provider/

cp ./configs/oai_provider/oaicat.properties ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_provider/

###############################################################################
# Init docker-compose
###############################################################################
cp docker-compose.yml ${OAI_INSTALL_DIRECTORY_ENV}
cp docker-compose4swarm.yml ${OAI_INSTALL_DIRECTORY_ENV}
cp docker-compose-with-cassandra.yml ${OAI_INSTALL_DIRECTORY_ENV}
cp ./configs/.env ${OAI_INSTALL_DIRECTORY_ENV}

#Set Environment
touch -a /etc/environment
while read line || [ -n "$line" ]; do
  if [[ ! $line =~ [^[:space:]] ]] || [[ $line = \#* ]] || [[ $line != *_ENV* ]]; then
    continue
  fi
  keyValue=(${line//=/ })
  sed -i "/^${keyValue[0]}/d" /etc/environment
  echo $line >> /etc/environment
done < "${OAI_INSTALL_DIRECTORY_ENV}/.env"

###############################################################################
# Copy examples
###############################################################################
mkdir -p ${OAI_INSTALL_DIRECTORY_ENV}/examples/
cp examples/* ${OAI_INSTALL_DIRECTORY_ENV}/examples
sed -i "s|@@OAI_EXTERNAL_BACKEND_URL@@|${OAI_EXTERNAL_BACKEND_URL}|g" ${OAI_INSTALL_DIRECTORY_ENV}/examples/createFormats.sh
sed -i "s|@@OAI_EXTERNAL_BACKEND_URL@@|${OAI_EXTERNAL_BACKEND_URL}|g" ${OAI_INSTALL_DIRECTORY_ENV}/examples/createCrosswalks.sh
sed -i "s|@@OAI_EXTERNAL_BACKEND_URL@@|${OAI_EXTERNAL_BACKEND_URL}|g" ${OAI_INSTALL_DIRECTORY_ENV}/examples/addItem.sh

###############################################################################
# Replace @@CASSANDRA_..@@ Values
###############################################################################
sed -i "s|@@CASSANDRA_SUPERUSER_PASSWORD@@|${CASSANDRA_SUPERUSER_PASSWORD}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/init-fizoai-database.sh
sed -i "s|@@CASSANDRA_PASSWORD@@|${CASSANDRA_PASSWORD}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/init-fizoai-database.sh
sed -i "s|@@CASSANDRA_PASSWORD@@|${CASSANDRA_PASSWORD}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/jmxremote.password
sed -i "s|@@CASSANDRA_PASSWORD@@|${CASSANDRA_PASSWORD}|g" ${OAI_INSTALL_DIRECTORY_ENV}/.cassandra_dump_env
sed -i "s|@@CASSANDRA_ADMIN_EMAIL@@|${CASSANDRA_ADMIN_EMAIL}|g" ${OAI_INSTALL_DIRECTORY_ENV}/.cassandra_dump_env
sed -i "s|@@CASSANDRA_HOSTNAME@@|${CASSANDRA_HOSTNAME}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/fiz-oai-backend.properties
sed -i "s|@@CASSANDRA_USER@@|${CASSANDRA_USER}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/fiz-oai-backend.properties
sed -i "s|@@CASSANDRA_PASSWORD@@|${CASSANDRA_PASSWORD}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/fiz-oai-backend.properties

###############################################################################
# Set Mod + Owners
###############################################################################
chmod +x ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra/wait-for-it.sh
chmod +x ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/wait-for-it.sh
chmod +x ${OAI_INSTALL_DIRECTORY_ENV}/examples/*.sh
chmod +x ${OAI_INSTALL_DIRECTORY_ENV}/data/cassandra-backup

chown -R ${ADMIN_USERNAME}:${ADMIN_GROUPNAME} ${OAI_INSTALL_DIRECTORY_ENV}
chown -R ${CASSANDRA_GROUPID}:${CASSANDRA_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/data/cassandra
chown -R ${CASSANDRA_GROUPID}:${CASSANDRA_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/configs/cassandra

chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/data/elasticsearch_oai/
chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/
chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/logs/elasticsearch_oai/

chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/data/oai_backend/
chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/
chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/logs/oai_backend/

chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/data/oai_provider/
chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_provider/
chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/logs/oai_provider/
