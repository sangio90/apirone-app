#!/bin/bash
set -e
git config --global --add safe.directory /var/www/vhosts/stage_apirone_cc_git/html
git pull origin master
touch ~/rilascio_stage.txt
echo "Rilascio stage $(date)" >> ~/rilascio_stage.txt