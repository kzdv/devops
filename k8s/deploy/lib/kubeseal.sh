#!/bin/bash

log " - Adding Helm repository"
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets

log " - Updating repositories"
helm repo update

log " - Installing Sealed Secrets"
helm install sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets

log " - Waiting for deployment to be ready"
kubectl rollout status -n kube-system deployment/sealed-secrets-controller