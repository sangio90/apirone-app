#!/bin/bash

set -a

source .env

set +a

PGPASSWORD=${LOCAL_DB_PASSWORD} /opt/homebrew/Cellar/postgresql@13/13.23/bin/psql -h ${LOCAL_DB_HOST} -U ${LOCAL_DB_USER} -d ${LOCAL_DB_NAME} -p ${LOCAL_DB_PORT} -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
PGPASSWORD=${LOCAL_DB_PASSWORD} /opt/homebrew/Cellar/postgresql@13/13.23/bin/psql -h ${LOCAL_DB_HOST} -U ${LOCAL_DB_USER} -d ${LOCAL_DB_NAME} -p ${LOCAL_DB_PORT} -c 'DROP SCHEMA backup CASCADE;'
PGPASSWORD=${LOCAL_DB_PASSWORD} /opt/homebrew/Cellar/postgresql@13/13.23/bin/psql -h ${LOCAL_DB_HOST} -U ${LOCAL_DB_USER} -d ${LOCAL_DB_NAME} -p ${LOCAL_DB_PORT} -c 'DROP SCHEMA membership CASCADE;'
PGPASSWORD=${LOCAL_DB_PASSWORD} /opt/homebrew/Cellar/postgresql@13/13.23/bin/psql -h ${LOCAL_DB_HOST} -U ${LOCAL_DB_USER} -d ${LOCAL_DB_NAME} -p ${LOCAL_DB_PORT} -c 'DROP SCHEMA utils CASCADE;'
PGPASSWORD=${LOCAL_DB_PASSWORD} /opt/homebrew/Cellar/postgresql@13/13.23/bin/psql -h ${LOCAL_DB_HOST} -U ${LOCAL_DB_USER} -d ${LOCAL_DB_NAME} -p ${LOCAL_DB_PORT} -f ./backup-database-apir-$(date +"%Y-%m-%d").sql -v ON_ERROR_STOP=1
