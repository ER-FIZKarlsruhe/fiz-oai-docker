#!/usr/bin/env bash

set -euo pipefail

BASE_DOI="10.5072"
START_NUMBER=38238
COUNT=500

BACKEND_URL="@@OAI_EXTERNAL_BACKEND_URL@@"
TEMPLATE_XML="item_template.xml"
WORKDIR="./generated_xml"

mkdir -p "${WORKDIR}"

for ((i=0; i<COUNT; i++)); do
    NUMBER=$((START_NUMBER + i))
    DOI="${BASE_DOI}/${NUMBER}"

    XML_FILE="${WORKDIR}/${BASE_DOI}-${NUMBER}.xml"

    # Create XML with correct DOI
    sed "s|__DOI__|${DOI}|g" "${TEMPLATE_XML}" > "${XML_FILE}"

    echo "Creating item for DOI ${DOI}"

    curl --noproxy '*' -s -X POST \
        -H 'Content-Type: multipart/form-data' \
        "${BACKEND_URL}/item" \
        -F "item={\"identifier\":\"${DOI}\",\"deleteFlag\":false,\"ingestFormat\":\"radar\"};type=application/json" \
        -F "content=@${XML_FILE}"

done

echo "✅ Successfully created ${COUNT} items"
