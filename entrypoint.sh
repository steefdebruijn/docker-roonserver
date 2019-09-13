#!/bin/bash
chown roonserver:roonserver /app /data /backup
exec /usr/local/bin/gosu roonserver /run.sh
