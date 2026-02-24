#!/bin/bash
set -e

git pull origin master
touch /var/log/rilascio_stage.txt
echo "Rilascio stage $(date)" >> /var/log/rilascio_stage.txt