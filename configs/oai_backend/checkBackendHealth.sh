#!/bin/bash

#Check if OAI-Backend-Http-Request returns status-code 200
URL="http://oai-backend:8080/oai-backend/info/version"

response=$(curl -L --noproxy '*' --write-out %{http_code} --silent --output /dev/null $URL)
if [[ "$response" -eq 200 ]]; then
  echo "Backend Status is OK"
  exit 0
else
  echo "Waiting for Backend Status OK"
  exit 1
fi

