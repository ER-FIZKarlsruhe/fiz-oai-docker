#Create Item for 10.5072-38238.xml
curl --noproxy '*' -v -X POST -H 'Content-Type: multipart/form-data' -i '@@OAI_EXTERNAL_BACKEND_URL@@/item'  -F "item={\"identifier\":\"10.5072/38238\",\"deleteFlag\":false,\"ingestFormat\":\"radar\"};type=application/json" -F content=@./10.5072-38238.xml
