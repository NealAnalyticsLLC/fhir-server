#!/bin/bash

echo "Creating namespace: fhir-server"
kubectl create namespace fhir-server

echo "Writing .env to fhir-env secret"
kubectl --namespace fhir-server create secret generic fhir-env  --from-env-file ./.env

read -p "Path to certificate file:" CERT_FILE
echo "Writing certificate to fhir-server-certificate"
kubectl --namespace fhir-server create secret generic fhir-server-certificate --from-file=$CERT_FILE