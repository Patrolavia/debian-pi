#!/bin/bash

SUDO=""
DOCKER="docker"

if [[ $(id -u) != 0 ]]
then
    SUDO="sudo"
fi

grep -F 'docker:x:' /etc/group | cut -d ':' -f 4 | grep -E "(^|,)$(id -un)(,|$)" > /dev/null 2>&1
if [[ $? != 0 ]]
then
    DOCKER="$SUDO $DOCKER"
fi

export SUDO DOCKER
