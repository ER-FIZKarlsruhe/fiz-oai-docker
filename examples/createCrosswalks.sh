#Create Crosswalk from radar to oai_dc
curl -X POST -H 'Content-Type: application/json' -i 'http://localhost:8081/oai-backend/format' --data '{"name":"Radar2OAI_DC_v09","formatFrom":"radar","formatTo":"oai_dc","xsltStylesheet":"`cat Radar2OAI_DC_v09.xsl`"}'
