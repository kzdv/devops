#!/bin/bash

log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $*"
}
export -f log