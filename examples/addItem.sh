#Create Item for 10.5072-38238.xml

curl -X POST -H 'Content-Type: application/json' -i 'http://localhost:8081/oai-backend/item' -d @10.5072-38238.xml --data "{"identifier":" 10.5072/38238","deleteFlag":false,"ingestFormat":"radar"}"