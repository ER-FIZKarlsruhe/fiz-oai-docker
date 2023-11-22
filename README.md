# Prerequirements
- Linux OS system
- The easiest and recommended way is to make sure you have the latest version of Docker Desktop, which bundles the Docker Engine and Docker CLI platform including Compose V2
- jq package (just needed for crosswalk examples)

# Installation
- For installation execute the following command. It will prepare the folder structure and configuration for the application in the given INSTALL_DIRECTORY  
- INSTALL_DIRECTORY must be an absolute path!

  *host:/$> sudo ./install.sh INSTALL_DIRECTORY CASSANDRA_SUPERUSER_PASSWORD CASSANDRA_PASSWORD*  

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

### Change cassandra JMX password  
For security reason you must change the default JMX password.

- Update cassandra JMX password for backup container  
  Edit INSTALL_DIR/.cassandra_dump_env and change  
  *CASSANDRA_PWD=NEW_JMX_PASSWORD*  

- Update JMX remote password for cassandra container  
  Edit INSTALL_DIR/configs/cassandra/jmxremote.password and change  
  *fizoaibackend NEW_JMX_PASSWORD*
  
  
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
