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



# Getting started

### Check installation
After starting the services you can call the following urls and see if the "oai-provider" and the "oai-backend" response

Oai-Provider: http://localhost:8080/oai/

Oai-Backend: http://eng-d-vm08.fiz-karlsruhe.de:8081/oai-backend/info/version

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

