#!/bin/bash

set -ex

namespace=$(kubectl get pod -A | grep sealed-secret | grep Running | awk '{print $1}')
controller=$(kubectl get deploy -n $namespace | grep sealed-secret | awk '{print $1}')

for file in $(find yaml/ -type f -name "secret*.yaml" -print); do
    dir=$(dirname $file)
    filename=$(basename $file)
    kubeseal --controller-name $controller --controller-namespace $namespace -o yaml <$file >$dir/sealed-$filename
done