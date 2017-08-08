#!/bin/bash
cd /app
if test ! -d RoonServer; then
        curl $ROON_SERVER_URL -O
        tar xjf $ROON_SERVER_PKG
        rm -f $ROON_SERVER_PKG
fi
/app/RoonServer/start.sh
