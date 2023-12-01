# Prerequirements
- Linux OS system
- The easiest and recommended way is to make sure you have the latest version of Docker Desktop, which bundles the Docker Engine and Docker CLI platform including Compose V2
- jq package (just needed for crosswalk examples)

# Installation
- Checkout this Git-Project onto docker-machine
- Ensure if you have sudo all rights on the machine.
- For installation execute the following command. It will prepare the folder structure and configuration for the application in the given INSTALL_DIRECTORY
  - *host:/$> **sudo** ./install.sh INSTALL_DIRECTORY CASSANDRA_SUPERUSER_PASSWORD CASSANDRA_PASSWORD*
- If you want to start with docker swarm, you have to set the environment with:
  - *host:/$> set -a; . /etc/environment; set +a;*

- INSTALL_DIRECTORY must be an absolute path!
- CASSANDRA_SUPERUSER_PASSWORD Password for the default-superuser with name "cassandra"
- CASSANDRA_PASSWORD Password for the User "fizoaibackend"

# Network-Strategies
- To write Data and configure OAI-Provider, decide if you want to access the OAI-Backend externally or Docker-Network-Internally.
- Access OAI-Backend externally:
  - Edit docker-compose.yml
    - Add port-mapping to oai-backend
      ```
      ports:
      - '8081:8080'
      ```
- Access OAI-Backend Docker-Network-Internally, join FIZ-OAI into existing Network
  - Check running Networks
      ```
      docker network ls
      ```
  - Edit docker-compose.yml
    - Join FIZ-OAI to exisiting Network
        ```
        networks:
          fizoai:
            external:
              name: <existing_network_name>
        ```

- Running the application  
  *host:/$> cd INSTALL_DIRECTORY*  
  *host:/$> sudo docker compose up*

# Getting started

### Check installation
After starting the services you can call the following urls and see if the "oai-provider" and the "oai-backend" response

Oai-Provider: http://localhost:8080/oai/

Oai-Backend: http://localhost:8081/oai-backend/info/version

### Create formats
You need at least the oai_dc format defined in the backend. This format is mandatory for all oai provider.
The script examples/createFormats.sh shows you how to create formats via curl.

### Create crosswalks (needs jq package)
If you want to automatically transform your metadata into other formats, you can use crosswalks. 
The commands in examples/createCrosswalks.sh shows you how Radar metadata can be transformed into oai_dc and datacite via XSLT.

### Create items
After creating at least the oai_dc format, you are able to send your metadata into the oai-backend.
Have a look at examples/addItem.sh. The curl command shows you how to create a multipart request to the backend. It contains of two parts  
1) The xml metadata itself  (content)  
2) An item description for the metadata in JSON (item)  



# Security
The FIZ-OAI has no security features, like authentication or autorization. If needed you can adapt Basic-Auth to the service.
The only Service allowed to be connected to the internet is the Oai-Provider. You should use vHost listening to 443 including a Reverse-Proxy and certificate for doing this:  

    <VirtualHost *:443>
        ServerName www.your-domain.edu
        ProxyPass /oai http://localhost:8080/oai
        ProxyPassReverse /oai http://localhost:8080/oai
    </VirtualHost>


# Cassandra Backup
A cronjob is creating regularly snapshots and backups of the cassandra database.
You can find them here: INSTALL_DIR/data/cassandra-backup

*You have to backup INSTALL_DIR/data/cassandra-backup for disaster recovery!*

# Branding
There are several parameters to configure the provider ui via
INSTALL_DIR/configs/oai_provider/oaicat.properties

```
branding.logo=/data/www/logo.jpg
branding.header.color=#97c6f4
branding.service.name=Testinstanz FIZ OAI Provider
branding.service.url=https://www.fiz-karlsruhe.de
branding.welcome.text=This is the FIZ OAI provider
branding.imprint.url=
branding.privacy.url=
branding.font.family=Verdana, Arial, Helvetica, sans-serif;
branding.font.color=#013476;
```

