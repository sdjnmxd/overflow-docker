#!/bin/sh

if [ -z "$JAVA_OPTS" ]; then
    JAVA_OPTS="-Xms512M -Xmx1G"
fi

export JAVA_OPTS

cd /app/mcl
exec ./mcl