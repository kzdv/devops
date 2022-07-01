#!/bin/bash

databases=($DATABASES)

mkdir backup
pushd backup

for db in "${databases[@]}"; do
  mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $db > $db.sql
done
popd

tar -czf backup-$(date +%F-%H%m).tar.gz backup
# upload to aws