#!/bin/bash

set -a

source .env

set +a

pg_dump \
	--no-owner \
	--dbname=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME} \
	> /home/${SSH_USER}/backup-database-apir-$(date +"%Y-%m-%d").sql"

PGPASSWORD=${STAGE_DB_PASSWORD} psql -h ${STAGE_DB_HOST} -U ${STAGE_DB_USER} -d ${STAGE_DB_NAME} -p ${STAGE_DB_PORT} -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
PGPASSWORD=${STAGE_DB_PASSWORD} psql -h ${STAGE_DB_HOST} -U ${STAGE_DB_USER} -d ${STAGE_DB_NAME} -p ${STAGE_DB_PORT} -c 'DROP SCHEMA backup CASCADE;'
PGPASSWORD=${STAGE_DB_PASSWORD} psql -h ${STAGE_DB_HOST} -U ${STAGE_DB_USER} -d ${STAGE_DB_NAME} -p ${STAGE_DB_PORT} -c 'DROP SCHEMA membership CASCADE;'
PGPASSWORD=${STAGE_DB_PASSWORD} psql -h ${STAGE_DB_HOST} -U ${STAGE_DB_USER} -d ${STAGE_DB_NAME} -p ${STAGE_DB_PORT} -c 'DROP SCHEMA utils CASCADE;'
PGPASSWORD=${STAGE_DB_PASSWORD} psql -h ${STAGE_DB_HOST} -U ${STAGE_DB_USER} -d ${STAGE_DB_NAME} -p ${STAGE_DB_PORT} -f /home/${SSH_USER}/backup-database-apir-$(date +"%Y-%m-%d").sql -v ON_ERROR_STOP=1

rm /home/${SSH_USER}/backup-database-apir-$(date +"%Y-%m-%d").sql

