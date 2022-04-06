#!/bin/sh

echo "Starting code-server . . ."
[ "${CODE_SERVER_PWD}" = "" ] && CODE_SERVER_PWD=$(echo $RANDOM | md5sum | head -c 20; echo;)
PASSWORD="${CODE_SERVER_PWD}" code-server \
	--bind-addr="0.0.0.0:${CODE_SERVER_PORT:=443}" \
	--auth="password" \
	--disable-telemetry=true \
	--disable-update-check=true \
	--cert="/root/.config/code-server/cert/server.crt" \
	--cert-key="/root/.config/code-server/cert/server.key" \
	>/dev/null 2>&1 &

echo "Running . . ."
tail -f /dev/null
