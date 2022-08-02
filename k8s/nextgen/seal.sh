#!/bin/bash

set -ex

for file in $(find . -type f -name "secrets*.yaml" -print); do
    dir=$(dirname $file)
    filename=$(basename $file)
    kubeseal --controller-name sealed-secrets --controller-namespace default -o yaml <$file >$dir/sealed-$filename
done