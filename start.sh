#!/bin/bash

if [ -z "$1" ]
then
    echo "Error: No project key specified." >&2
    exit 1
fi

ln -fs /config/* ./config/

env_configs="./config/env_vars.sh"
if [ -e $env_configs ]
then
    source $env_configs
fi

rake project:load[$1]

exec bundle exec rails server -p 80
