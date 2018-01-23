#!/bin/bash

if [ -n "${http_proxy}" ]; then
	PROXYSERVER=$(echo $http_proxy | sed -E 's/^http://' | sed -E 's/\///g' | sed -E 's/(.*):(.*)/\1/');
	PROXYPORT=$(echo $http_proxy | sed -E 's/^http://' | sed -E 's/\///g' | sed -E 's/(.*):(.*)/\2/');
	JAVA_ARGS="$JAVA_ARGS -Dhttp.proxyHost=${PROXYSERVER} -Dhttp.proxyPort=${PROXYPORT} -Dhttps.proxyHost=${PROXYSERVER} -Dhttps.proxyPort=${PROXYPORT}";
fi
