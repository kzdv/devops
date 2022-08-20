#!/bin/bash

if ! command -v argocd >/dev/null &>/dev/null; then
  echo "argocd is not installed"
  exit 1
fi

if ! command -v kubectl >/dev/null &>/dev/null; then
  echo "kubectl is not installed"
  exit 1
fi

if ! command -v helm >/dev/null &>/dev/null; then
  echo "helm is not installed"
  exit 1
fi

if ! command -v jq >/dev/null &>/dev/null; then
  echo "jq is not installed"
  exit 1
fi

if ! command -v yq >/dev/null &>/dev/null; then
  echo "yq is not installed"
  exit 1
fi
