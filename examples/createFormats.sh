#Create OAI_DC Format
printf "\n\nCreate Format oai_dc\n\n"
curl --noproxy '*' -X POST -H 'Content-Type: application/json' -i '@@OAI_EXTERNAL_BACKEND_URL@@/format' --data '{"metadataPrefix":"oai_dc","schemaLocation":"http://www.openarchives.org/OAI/2.0/oai_dc.xsd","schemaNamespace":"http://www.openarchives.org/OAI/2.0/oai_dc/","identifierXpath":"/identifier"}'

#Create RADAR Format
printf "\n\nCreate Format radar\n\n"
curl --noproxy '*' -X POST -H 'Content-Type: application/json' -i '@@OAI_EXTERNAL_BACKEND_URL@@/format' --data '{"metadataPrefix":"radar","schemaLocation":"https://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset/","schemaNamespace":"http://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset/","identifierXpath":""}'

#Create Datacite Format
printf "\n\nCreate Format datacite\n\n"
curl --noproxy '*' -X POST -H 'Content-Type: application/json' -i '@@OAI_EXTERNAL_BACKEND_URL@@/format' --data '{"metadataPrefix":"datacite","schemaLocation":"https://schema.datacite.org/meta/kernel-4.0/metadata.xsd","schemaNamespace":"http://datacite.org/schema/kernel-4","identifierXpath":""}'

#Read all formats
#curl --noproxy '*' -X GET '@@OAI_EXTERNAL_BACKEND_URL@@/format'
