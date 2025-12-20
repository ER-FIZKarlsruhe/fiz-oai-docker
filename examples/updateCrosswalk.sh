
XSLT=`cat dc.xsl | jq -Rsa .`

#Update specific crosswalk
curl --noproxy '*' -X DELETE -H 'Content-Type: application/json' -i '@@OAI_EXTERNAL_BACKEND_URL@@/oai-backend/crosswalk/Radar2OAI_DC_v09'
curl --noproxy '*' -X POST -H 'Content-Type: application/json' -i '@@OAI_EXTERNAL_BACKEND_URL@@/oai-backend/crosswalk' --data '{"name":"Radar2OAI_DC_v09","formatFrom":"radar","formatTo":"oai_dc","xsltStylesheet":'"$XSLT"'}'
