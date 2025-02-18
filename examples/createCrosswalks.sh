#The examples below use the linux command jq for encoding teh XSLT to JSON for adding it into the curl command
#The package can be installed via yum install jq

#Create Crosswalk from radar to oai_dc
XSLT_RADAR_DC=`cat Radar2OAI_DC_v9.1.xsl | jq -Rsa .`
XSLT_RADAR_DATACITE=`cat RadarMD-v9.1-to-DataciteMD-v4_4.xslt | jq -Rsa .`
printf "\n\nCreate Crosswalk radar2oai_dc\n\n"
curl --noproxy '*' -X POST -H 'Content-Type: application/json' -i '@@OAI_EXTERNAL_BACKEND_URL@@/crosswalk' --data '{"name":"Radar2OAI_DC_v09","formatFrom":"radar","formatTo":"oai_dc","xsltStylesheet":'"$XSLT_RADAR_DC}"'}'

#Create Crosswalk from radar to datacite
XSLT_JSON_ENCODED=`cat RadarMD-v9.1-to-DataciteMD-v4_4.xslt | jq -Rsa .`
printf "\n\nCreate Crosswalk radar2datacite\n\n"
curl --noproxy '*' -X POST -H 'Content-Type: application/json' -i '@@OAI_EXTERNAL_BACKEND_URL@@/crosswalk' --data '{"name":"Radar2datacite","formatFrom":"radar","formatTo":"datacite","xsltStylesheet":'"$XSLT_RADAR_DATACITE}"'}'


#Read all crosswalk
#curl --noproxy '*' -X GET '@@OAI_EXTERNAL_BACKEND_URL@@/crosswalk'


#Delete specific crosswalk
#curl --noproxy '*' -v -X DELETE @@OAI_EXTERNAL_BACKEND_URL@@/crosswalk/Radar2OAI_DC_v09
