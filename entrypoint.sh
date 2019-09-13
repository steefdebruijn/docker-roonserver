#!/bin/bash
chown roonserver:roonserver /app /data /backup
exec /usr/sbin/gosu roonserver /run.sh
