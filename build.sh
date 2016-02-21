#!/bin/bash

REPO=$1

if [[ $REPO == "" ]]
then
    REPO="http://ftp.tw.debian.org/debian"
fi

shift

set -e

IMG="patrolavia/debian-pi"

for VER in stretch jessie wheezy
do
    ./make-image.sh $IMG $VER $REPO "$@"
done

set +e
source lib.sh

$DOCKER tag -f $IMG:stretch $IMG:testing
$DOCKER tag -f $IMG:jessie $IMG:stable
$DOCKER tag -f $IMG:wheezy $IMG:oldstable
$DOCKER tag -f $IMG:jessie $IMG:latest

$DOCKER push $IMG
