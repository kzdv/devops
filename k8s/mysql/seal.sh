#!/bin/bash

kubeseal --controller-name sealed-secrets --controller-namespace default -o yaml <backup/secrets.yaml >backup/secrets-sealed.yaml