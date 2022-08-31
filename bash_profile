#!/bin/bash

trap '' INT

launch_docker_workspace () (
	trap - INT
	echo "Launching docker-workspace . . ."
	sleep 0.5
	docker exec -it docker-workspace zsh
	return 0
)

if launch_docker_workspace; then
	exit
fi
