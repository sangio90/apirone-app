#!/bin/bash
set -e
git config --global --add safe.directory /var/www/vhosts/stage_apirone_cc_git/html
git pull origin master
touch /var/log/rilascio_stage.txt
echo "Rilascio stage $(date)" >> /var/log/rilascio_stage.txt