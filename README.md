# Prerequirements
- Linux OS system
- Docker package installed
- Docker-Compose package installed
- jq package (just needed for crosswalk examples)

# Installation
1) For installation execute the following command. It will prepare the folder structure and configuration for the application in the given INSTAL_DIRECTORY  
  
sudo ./install.sh INSTAL_DIRECTORY

2) Running the application  
  
cd INSTAL_DIRECTORY  
sudo docker-compose up

3) Change the password of the Cassandra database

- Connect to cassandra  
Retrieve cassandra containerId via  
sudo docker container ls

From the Docker-Host open bash in the container  
sudo docker exec -it <cassandra containerId> bash  
cqlsh -u cassandra

- Set new Password via cqlsh shell  
ALTER USER cassandra WITH PASSWORD 'NEW_PASSWORD';  


4) Change cassandra password 
- Update cassandra password for the oai-backend.  
Edit INSTALL_DIR/configs/oai_backend/fiz-oai-backend.properties and change  
cassandra.password='NEW_PASSWORD'

- Update password for cassandra-backup  
Edit INSTALL_DIR/.cassandra_dump_env and change  
CASSANDRA_PWD='NEW_PASSWORD'

# Getting started

### Check installation
After starting the services you can call the following urls and see if the "oai-provider" and the "oai-backend" response

Oai-Provider: http://localhost:8080/oai/

Oai-Backend: http://localhost:8081/oai-backend/info/version

### Create formats
You need at least the oai_dc format defined int the backend. This ofrmat is mandatory for all oai provider.
The script examples\createFormats.sh shows you how to create formats via curl.

### Create crosswalks (needs jq package)
If you want to automatically transfer your metadata into other formats, you can use crosswalks. 
The example in examples\createCrosswalks.sh shows you how Radar metadata can be transformed into oai_dc and datacite via XSLT.

### Create items
After creating at least the oai_dc format, you are able to send your metadata into the oai-backend.
Have a look at examples\addItem.sh how to do this. The reuqest contain two parts  
1) The xml metadata itself  
2) An item description for the metadata in JSON



# Security
The FIZ-OAI has no security features, like authentication or autorization. If needed you have can adapt Basic-Auth to the service.

The only Service that should be connected to the internet is the Oai-Provider. You should use vHost including a Reverse-Proxy for doing this:  

    <VirtualHost *:443>
        ServerName www.your-domain.edu
        ProxyPass /oai http://oai-provider:8080/oai
        ProxyPassReverse /oai http://oai-provider:8080/oai
    </VirtualHost>


# Cassandra Backup
A cronjob is creating regalarly snapshots and backups of the cassandra database.
You can find them here: INSTALL_DIR/data/cassandra-backup

Please backup these files for desaster recovery