#!/bin/bash

set -ex

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

pushd $SCRIPTPATH/base/secrets

if ! command -v kubeseal &>/dev/null; then
  echo "Missing required command: kubeseal"
  exit 1
fi

for file in secret*.yaml; do
    if [[ -f "$file" ]]; then
      kubeseal <"$file" >sealed-$file
    fi
done

popd