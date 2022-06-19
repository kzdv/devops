#!/bin/bash

kubectl port-forward -n mysql svc/mysql 3306:3306
