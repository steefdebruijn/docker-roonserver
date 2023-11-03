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

## Systemd

If you deploy on a host with `systemd`, you should use a systemd service to start the Roon service.

Example `systemd` service (adapt to your environment):

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

## Docker-compose

If you deploy in a `docker-compose` environment, create a `docker-compose.yaml` file and run `docker-compose run <service>`.

Example `docker-compose.yaml` (adapt to your environment):

    version: "3.7"
    services:
      docker-roonserver:
        image: steefdebruijn/docker-roonserver:latest
        container_name: docker-roonserver
        hostname: docker-roonserver
        network_mode: host
        environment:
          TZ: "Europe/Amsterdam"
        volumes:
          - roon-app:/app
          - roon-data:/data
          - roon-music:/music
          - roon-backups:/backup
        restart: always
    volumes:
      roon-app:
      roon-data:
      roon-music:
      roon-backups:


## Network shares

If you find yourself in trouble using remote SMB/CIFS shares, you probably need some additional privileges on the container.
You have two options here (see also issue #15):

Run the Roon container in privileged mode

    # standalone or from systemd service:
    docker run --privileged --name roonserver ...

    # docker-compose.yaml (inside service section):
    privileged: true

Run the Roon container with the right privileges. Some of these are docker-related, but depending on your host distribution and security settings you may need additional privileges.

    # standalone or from systemd service:
    docker run --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined ...
    
    # docker-compose.yaml (inside service section):
    cap_add:
      - SYS_ADMIN
      - DAC_READ_SEARCH
    security_opt:
      - apparmor:unconfined


## Network issues

  If your docker host has multiple networks attached and your core has trouble finding audio sinks/endpoints, you can try using a specific docker network setup as described in issue #1:

    docker network create -d macvlan \
       --subnet 192.168.1.0/24 --gateway 192.168.1.1 \
       --ip-range 192.168.1.240/28 -o parent=enp4s0 roon-lan
    docker run --network roon-lan --name roonserver ...

  Use the subnet and corresponding gateway that your audio sinks/endpoints are connected to. Use an ip-range for docker that is not conflicting with other devices on your network and outside of the DHCP range on that subnet if applicable.

## Extensions

If you would like to use the Roon extensions, please deploy a separate docker container for the extension manager, for example [this one](https://hub.docker.com/r/theappgineer/roon-extension-manager).
I have not tried this myself, I do not use Roon extensions.

## Backups

  Don't forget to backup the `roon-backups` *for real* (offsite preferably).

  Have fun!
  
  Steef

## Version history

  * 2023-11-03: update base image to 'debian:12-slim', dependency to libicu72
  * 2022-04-12: update base image to 'debian:11-slim'
  * 2022-03-19: Fix download URL, follow redirects on download. Added specific usage scenarios in README.
  * 2021-05-24: update base image to `debian:10.9-slim` and check for shared `/app` and `/data` folders.
  * 2019-03-18: Fix example start (thanx @heapxor); add `systemd` example.
  * 2019-01-23: updated base image to `debian-9.6`
  * 2017-08-08: created initial images based on discussion on roonlabs forum


