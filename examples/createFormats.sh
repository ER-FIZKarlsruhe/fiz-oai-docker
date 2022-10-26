#Create OAI_DC Format
curl -X POST -H 'Content-Type: application/json' -i 'http://localhost:8081/oai-backend/format' --data '{"metadataPrefix":"oai_dc","schemaLocation":"http://www.openarchives.org/OAI/2.0/oai_dc.xsd","schemaNamespace":"http://www.openarchives.org/OAI/2.0/oai_dc/","identifierXpath":"/identifier"}'

#Create RADAR Format
curl -X POST -H 'Content-Type: application/json' -i 'http://localhost:8081/oai-backend/format' --data '{"metadataPrefix":"radar","schemaLocation":"https://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset/","schemaNamespace":"http://radar-service.eu/schemas/descriptive/radar/v09/radar-dataset/","identifierXpath":""}'

#Create Datacite Format
curl -X POST -H 'Content-Type: application/json' -i 'http://localhost:8081/oai-backend/format' --data '{"metadataPrefix":"datacite","schemaLocation":"https://schema.datacite.org/meta/kernel-4.0/metadata.xsd","schemaNamespace":"http://datacite.org/schema/kernel-4","identifierXpath":""}'

#Read all formats
curl -X GET 'http://localhost:8081/oai-backend/format'