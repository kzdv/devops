#!/bin/bash

set -e

script_dir="$(dirname "$0")"
script_name="$(basename "$0")"
env=$1

. $script_dir/lib/common.sh

./$script_dir/lib/checks.sh

if [[ $env != "dev" && $env != "prod" && $env == "local" ]]; then
  echo "Usage: $0 <dev|prod|local>"
  exit 1
fi

log "Installing ArgoCD"
./$script_dir/lib/argocd.sh

log "Applying Application resource"
kubectl apply -f $script_dir/yaml/application-$env.yaml

log "Done. ArgoCD should deploy the cluster shortly."