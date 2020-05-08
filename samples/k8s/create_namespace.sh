#!/bin/bash
kubectl create namespace fhir-server
kubectl create secret generic fhir-env --namespace fhir-server --from-env-file ./.env
