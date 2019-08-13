#!/bin/bash

# make sure we are at the top of the git directory
REPOLOC="$(git rev-parse --show-toplevel)"
cd $REPOLOC

# load config
DBNAME=$(cat $REPOLOC/pluto.config.json | jq -r '.DBNAME')
DBUSER=$(cat $REPOLOC/pluto.config.json | jq -r '.DBUSER')

start=$(date +'%T')
echo "Starting to generate corrections for PLUTO"
psql -U $DBUSER -d $DBNAME -f $REPOLOC/pluto_build/sql/corr_yearbuilt_lpc.sql