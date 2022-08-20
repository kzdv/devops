#!/bin/bash

script_dir="$(dirname "$0")"

log "Installing ArgoCD"
kubectl create namespace argocd
kubectl apply -f "$script_dir/../yaml/argocd.yaml"

log "Waiting for ArgoCD to be ready"
while true; do
  if kubectl get pods -n argocd | grep -q "Running"; then
    break
  fi
  sleep 1
done