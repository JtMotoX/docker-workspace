#!/bin/sh

groupadd --gid 16 docker
usermod -a -G docker dw