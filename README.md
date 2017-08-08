# docker-roonserver
RoonServer downloading Roon on first run

This little project configures a docker image for running RoonServer.
It downloads RoonServer if not found on an external volume.

Example start:

    docker run --daemon \
      --net=host \
      -e TZ="Europe/Amsterdam" \
      -v roon-app:/app \
      -v roon-data:/data \
      -v roon-music:/music \
      -v roon-backups:/backup \
      steefdebruijn/docker-roonserver
  
  * You should set `TZ` to your timezone.
  * You can change the volume mappings to local file system paths if you like.
  * You should set up your library root to `/music` and configure backups to `/backup` on first run.
  
  Have fun!
  
  Steef
