#!/bin/sh

box server start \
  --nogui \
  --foreground \
  jvm.args="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:9999 -javaagent:/app/extras/luceedebug.jar=jdwpHost=127.0.0.1,jdwpPort=9999,debugHost=0.0.0.0,debugPort=10000,jarPath=/app/extras/luceedebug.jar" \
  jvm.heapSize=4096 \
  jvm.minHeapSize=1024


tail -f /dev/null
