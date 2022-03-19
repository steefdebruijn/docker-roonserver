#!/bin/bash

# Check folder existence
if test ! -w /app; then
    echo "Application folder /app not present or not writable"
    exit 1
fi
if test ! -w /data; then
    echo "Data folder /data not present or not writable"
    exit 1
fi

# Check for shared folders which cause all kinds of weird errors on core updates
rm -f /data/check-for-shared-with-data
touch /app/check-for-shared-with-data
if test -f /data/check-for-shared-with-data; then
    echo "Application folder /app and Data folder /data are shared. Please fix this."
    exit 1
fi
rm -f /app/check-for-shared-with-data

# Optionally download the app
cd /app
if test ! -d RoonServer; then
    if test -z "$ROON_SERVER_URL" -o -z "$ROON_SERVER_PKG"; then
	echo "Missing URL ROON_SERVER_URL and/or app name ROON_SERVER_PKG"
	exit 1
    fi
    curl -L $ROON_SERVER_URL -O
    tar xjf $ROON_SERVER_PKG
    rm -f $ROON_SERVER_PKG
fi

# Run the app
if test -z "$ROON_DATAROOT" -o -z "$ROON_ID_DIR"; then
    echo "Dataroot ROON_DATAROOT and/or ID dir ROON_ID_DIR not set"
    exit 1
fi
/app/RoonServer/start.sh
