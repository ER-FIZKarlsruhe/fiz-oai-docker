#Create Item for 10.5072-38238.xml

curl -X POST -H -i 'http://localhost:8081/oai-backend/item' -d content=@10.5072-38238.xml --data metadataJson='{"identifier":" 10.5072/38238","deleteFlag":false,"ingestFormat":"radar"}'


curl -v -X POST -H 'Content-Type: multipart/form-data' -i 'http://localhost:8081/oai-backend/item'  -F item=@10.5072-38238-item.json -F content=@10.5072-38238.xml
