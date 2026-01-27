#!/bin/sh

current_date_time="`date "+%Y-%m-%d %H:%M:%S"`";
echo '-------------------------'
echo 'CLOC COUNTER'
echo $current_date_time;
echo '-------------------------'

cloc ../apps/ ../com/ ../config/ ../layouts/ ../resources/ ../tests/ ../tasks/ ../assets/
