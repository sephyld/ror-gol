#! /usr/bin/bash

docker build -t sephyld/ror-gol .
WD=`pwd`
KEY=`cat "$WD/config/master.key"`
docker run -p 80:80 -e RAILS_MASTER_KEY="$KEY" sephyld/ror-gol