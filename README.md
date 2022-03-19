# docker-roonserver
RoonServer downloading Roon on first run

This little project configures a docker image for running RoonServer.
It downloads RoonServer if not found on an external volume.

Example start:

    docker run -d \
      --net=host \
      -e TZ="Europe/Amsterdam" \
      -v roon-app:/app \
      -v roon-data:/data \
      -v roon-music:/music \
      -v roon-backups:/backup \
      steefdebruijn/docker-roonserver:latest
  
  * You should set `TZ` to your timezone.
  * You can change the volume mappings to local file system paths if you like.
  * You *must* use different folders for `/app` and `/data`.
    The app will not start if they both point to the same folder or volume on your host.
  * You should set up your library root to `/music` and configure backups to `/backup` on first run.


Example `systemd` service:

    [Unit]
    Description=Roon
    After=docker.service
    Requires=docker.service
    
    [Service]
    TimeoutStartSec=0
    TimeoutStopSec=180
    ExecStartPre=-/usr/bin/docker kill %n
    ExecStartPre=-/usr/bin/docker rm -f %n
    ExecStartPre=/usr/bin/docker pull steefdebruijn/docker-roonserver
    ExecStart=/usr/bin/docker \
      run --name %n \
      --net=host \
      -e TZ="Europe/Amsterdam" \
      -v roon-app:/app \
      -v roon-data:/data \
      -v roon-music:/music \
      -v roon-backups:/backup \
      steefdebruijn/docker-roonserver
    ExecStop=/usr/bin/docker stop %n
    Restart=always
    RestartSec=10s
    
    [Install]
    WantedBy=multi-user.target

  If your docker host has multiple networks attached and your core has trouble finding audio sinks/endpoints, you can try using a specific docker network setup as described in issue #1:

    docker network create -d macvlan \
       --subnet 192.168.1.0/24 --gateway 192.168.1.1 \
       --ip-range 192.168.1.240/28 -o parent=enp4s0 roon-lan
    docker run --network roon-lan --name roonserver ...

  Use the subnet and corresponding gateway that your audio sinks/endpoints are connected to. Use an ip-range for docker that is not conflicting with other devices on your network and outside of the DHCP range on that subnet if applicable.

  Don't forget to backup the `roon-backups` *for real* (offsite preferably).

  Have fun!
  
  Steef

## Version history

  * 2022-03-19: Fix download URL, follow redirects on download. Added specific usage scenarios in README.
  * 2021-05-24: update base image to `debian-10.9-slim` and check for shared `/app` and `/data` folders.
  * 2019-03-18: Fix example start (thanx @heapxor); add `systemd` example.
  * 2019-01-23: updated base image to `debian-9.6`
  * 2017-08-08: created initial images based on discussion on roonlabs forum

