#!/bin/bash

if [ -z "$1" ]
then
    echo "Error: No project key specified." >&2
    exit 1
fi

if [ -f /run/secrets/environment ]
then
  source /run/secrets/environment
fi

if [ ! -d /config/ ]
then
    ln -s /run/secrets/ /config
fi

ln -fs /config/* ./config/

exec bundle exec rails server -p 80
