#!/bin/bash

set -a

source .env

set +a

ssh -p ${SSH_PORT} -t ${SSH_USER}@test-crm.apirone.cc \
    "pg_dump \
    	--no-owner \
     	--dbname=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME} \
     	> /home/${SSH_USER}/backup-database-apir-$(date +"%Y-%m-%d").sql && \
        tar -czvf backup-database-apir-$(date +"%Y-%m-%d").sql.tar.gz backup-database-apir-$(date +"%Y-%m-%d").sql && \
        rm backup-database-apir-$(date +"%Y-%m-%d").sql"
scp -P ${SSH_PORT} ${SSH_USER}@test-crm.apirone.cc:/home/${SSH_USER}/backup-database-apir-$(date +"%Y-%m-%d").sql.tar.gz ./
ssh -p ${SSH_PORT} -t ${SSH_USER}@test-crm.apirone.cc "rm backup-database-apir-$(date +"%Y-%m-%d").sql.tar.gz"
tar -xzvf backup-database-apir-$(date +"%Y-%m-%d").sql.tar.gz
rm backup-database-apir-$(date +"%Y-%m-%d").sql.tar.gz

