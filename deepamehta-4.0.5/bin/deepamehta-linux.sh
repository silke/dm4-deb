#!/bin/sh
cd "$(dirname "$0")"
exec java -Dfile.encoding=UTF-8 -Dfelix.system.properties=file:/etc/deepamehta/config.properties -jar bin/felix.jar
