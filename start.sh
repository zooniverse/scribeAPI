#!/bin/bash

if [ -z "$1" ]
then
    echo "Error: No project key specified." >&2
    exit 1
fi

ln -fs /config/* ./config/

exec bundle exec rails server -p 80
