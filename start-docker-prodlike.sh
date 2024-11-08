#! /usr/bin/bash

WD=`pwd`

rm $WD/config/credentials.yml.enc
$WD/bin/rails credentials:edit

docker build -t sephyld/ror-gol .

KEY=`cat "$WD/config/master.key"`

docker run -p 80:80 -e RAILS_MASTER_KEY="$KEY" sephyld/ror-gol