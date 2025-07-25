#!/bin/bash

#Read .env and fill it in Variables
while read line || [ -n "$line" ]; do
  if [[ ! $line =~ [^[:space:]] ]] || [[ $line = \#* ]]; then
    continue
  fi
  IFS='=' read -r key value <<< ${line}
  eval ${key}=\${value}
done < "configs/.env"

echo "fiz-oai-docker will be installed to ${OAI_INSTALL_DIRECTORY_ENV}"

###########################################################################
# Add groups and users
###########################################################################
sudo groupadd --gid ${OAI_BACKEND_GROUPID} oai_backend > /dev/null 2>&1
sudo groupadd --gid ${OAI_PROVIDER_GROUPID} oai_provider > /dev/null 2>&1
sudo groupadd --gid ${ELASTICSEARCH_GROUPID} oai_elasticsearch > /dev/null 2>&1

sudo useradd -u ${OAI_BACKEND_GROUPID} -g ${OAI_BACKEND_GROUPID} oai_backend > /dev/null 2>&1
sudo useradd -u ${OAI_PROVIDER_GROUPID} -g ${OAI_PROVIDER_GROUPID} oai_provider > /dev/null 2>&1
sudo useradd -u ${ELASTICSEARCH_GROUPID} -g ${ELASTICSEARCH_GROUPID} oai_elasticsearch > /dev/null 2>&1

sudo usermod -a -G ${OAI_BACKEND_GROUPID} oai_backend > /dev/null 2>&1
sudo usermod -a -G ${OAI_PROVIDER_GROUPID} oai_provider > /dev/null 2>&1
sudo usermod -a -G ${ELASTICSEARCH_GROUPID} oai_elasticsearch > /dev/null 2>&1

sudo usermod -a -G ${OAI_BACKEND_GROUPID} ${ADMIN_USERNAME} > /dev/null 2>&1
sudo usermod -a -G ${OAI_PROVIDER_GROUPID} ${ADMIN_USERNAME} > /dev/null 2>&1
sudo usermod -a -G ${ELASTICSEARCH_GROUPID} ${ADMIN_USERNAME} > /dev/null 2>&1

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
cp ./configs/.cassandra_dump_env ${OAI_INSTALL_DIRECTORY_ENV}

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
sed -i "s|@@OAI_EXTERNAL_BACKEND_URL@@|${OAI_EXTERNAL_BACKEND_URL}|g" ${OAI_INSTALL_DIRECTORY_ENV}/examples/updateCrosswalk.sh
sed -i "s|@@OAI_EXTERNAL_BACKEND_URL@@|${OAI_EXTERNAL_BACKEND_URL}|g" ${OAI_INSTALL_DIRECTORY_ENV}/examples/addItem.sh

###############################################################################
# Replace @@CASSANDRA_..@@ Values
###############################################################################
sed -i "s|@@CASSANDRA_HOSTNAME@@|${CASSANDRA_HOSTNAME}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/fiz-oai-backend.properties
sed -i "s|@@CASSANDRA_USER@@|${CASSANDRA_USER}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/fiz-oai-backend.properties
sed -i "s|@@CASSANDRA_PASSWORD@@|${CASSANDRA_PASSWORD}|g" ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/fiz-oai-backend.properties

###############################################################################
# Set Mod + Owners
###############################################################################
sudo chmod +x ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/wait-for-it.sh
sudo chmod +x ${OAI_INSTALL_DIRECTORY_ENV}/examples/*.sh

sudo chown -R ${ADMIN_USERNAME}:${ADMIN_GROUPNAME} ${OAI_INSTALL_DIRECTORY_ENV}
sudo chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/data/elasticsearch_oai/
sudo chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/configs/elasticsearch_oai/
sudo chown -R ${ELASTICSEARCH_GROUPID}:${ELASTICSEARCH_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/logs/elasticsearch_oai/

sudo chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/data/oai_backend/
sudo chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_backend/
sudo chown -R ${OAI_BACKEND_GROUPID}:${OAI_BACKEND_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/logs/oai_backend/

sudo chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/data/oai_provider/
sudo chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/configs/oai_provider/
sudo chown -R ${OAI_PROVIDER_GROUPID}:${OAI_PROVIDER_GROUPID} ${OAI_INSTALL_DIRECTORY_ENV}/logs/oai_provider/

sudo chmod -R 775 ${OAI_INSTALL_DIRECTORY_ENV}/configs
