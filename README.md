# [Roon Server Image](https://github.com/NobleFactor/roonserver-image)

A Docker image that automatically installs, configures, and runs Roon Server in a container. The installation and configuration is handled by the `install-roonserver` script on first run.

## Quick Start

### Using Make (Recommended)

```bash
# View all available commands
make help

# Build and create the Roon Server container
make New-RoonServer

# Start the Roon Server
make Start-RoonServer
```

### Using Docker Compose

```bash
# Create and start the container
docker compose up -d

# View logs
docker compose logs -f
```

### Using Docker CLI

```bash
docker run -d \
  --name roonserver \
  --net=host \
  -v ~/Documents/Roon/Backup:/opt/local/var/roon/backup \
  -v ~/Documents/Roon/Data:/opt/local/var/roon/data \
  -v ~/Documents/Roon/Music:/opt/local/var/roon/music \
  noblefactor/roonserver:latest
```

## macOS Notes

- This Roon server container was developed and tested on macOS using [OrbStack](https://orbstack.dev/) as a drop-in replacement for Docker Desktop.
- On macOS, it is best to test from a remote device (e.g., an iPad) using the [Roon Remote app](https://apps.apple.com/us/app/roon-remote/id1014764083) (available in the App Store). This avoids conflicts between the containerized Roon server and Roon for Mac running on the same machine.
- On first execution, you will asked to authorize Roon Server access to the Roon backup, data, and music volumes. These are currently hardwired to:
  - ~/Documents/Roon/Backup
  - ~/Documents/Roon/Data
  - ~/Documents/Roon/Music/

  See [`docker-compose.yml`](./docker-compose.yml).

## Architecture

This project uses a custom installation script that:

1. **Detects Installation State**: Checks if Roon Server is already installed
2. **First Run**: Downloads and installs Roon Server from official sources
3. **Subsequent Runs**: Simply starts the existing installation
4. **Container-Aware**: Automatically detects Docker environments and skips privileged systemctl operations

### Directory Structure

- **ROON_SERVERROOT**: `/opt/local/share/roon/roonserver` - Roon Server application files
- **ROON_DATAROOT**: `/opt/local/var/roon` - Roon Server data root
  - `/opt/local/var/roon/data` - Database and configuration
  - `/opt/local/var/roon/music` - Music library
  - `/opt/local/var/roon/backup` - Backup location

**Important**: The server and data directories must be separate. The installation script enforces this to prevent update issues.

## Configuration

### Environment Variables

- **ROON_SERVERROOT**: Override default server installation path (default: `/opt/local/share/roon/roonserver`)
- **ROON_DATAROOT**: Override default data root path (default: `/opt/local/var/roon`)

### Install Script Options

The `install-roonserver` script supports:

- `--package <address>`: Custom download URL for Roon Server package (default: official Roon Labs URL)
- `--timezone <timezone>`: Set container timezone (default: `Etc/UTC`)
- `--help`: Display usage information

## Docker Compose Configuration

The included `docker-compose.yml` provides a complete configuration:

```yaml
services:
  roonservice:
    image: ${IMAGE:-noblefactor/roonserver}
    container_name: roonserver
    platform: linux/amd64
    hostname: roonserver
    network_mode: host
    restart: always
    volumes:
      - type: bind
        source: ~/Documents/Roon/Backup
        target: /opt/local/var/roon/backup
      - type: bind
        source: ~/Documents/Roon/Data
        target: /opt/local/var/roon/data
      - type: bind
        source: ~/Documents/Roon/Music
        target: /opt/local/var/roon/music
```

**Customize the volume paths** to match your environment.

## Network Shares

If you encounter issues using remote SMB/CIFS shares, you may need additional container privileges.

### Option 1: Privileged Mode

```bash
# Docker CLI
docker run --privileged --name roonserver ...

# docker-compose.yml
privileged: true
```

### Option 2: Specific Capabilities

```bash
# Docker CLI
docker run --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined ...

# docker-compose.yml
cap_add:
  - SYS_ADMIN
  - DAC_READ_SEARCH
security_opt:
  - apparmor:unconfined
```

## Network Configuration

If your Docker host has multiple networks and your core has trouble finding audio endpoints, try using a macvlan network:

```bash
docker network create -d macvlan \
   --subnet 192.168.1.0/24 --gateway 192.168.1.1 \
   --ip-range 192.168.1.240/28 -o parent=enp4s0 roon-lan

docker run --network roon-lan --name roonserver ...
```

Use the subnet and gateway that match your audio endpoints. Choose an IP range that doesn't conflict with DHCP or other devices.

## Extensions

For Roon extensions, deploy a separate container for the extension manager, such as [theappgineer/roon-extension-manager](https://hub.docker.com/r/theappgineer/roon-extension-manager).

## Sound cards on host

If you want to use soundcard(s) attached to docker host, try mounting the soundcard device(s) to the roon container.

Direct or via systemd:

    docker run --device /dev/snd:/dev/snd ....

or via compose:

    devices:
      - "/dev/snd:/dev/snd"

See also issue #26.

## Backups

**Important**: Always maintain offsite backups of your `/opt/local/var/roon/backup` volume.

## Development

### Building the Image

```bash
make New-RoonServer
```

Or manually:

```bash
docker buildx build --platform linux/amd64 --tag noblefactor/roonserver:1.0.0-preview.2 . --progress=plain
```

### Shell Access

```bash
make Start-RoonServerShell
```

Or manually:

```bash
docker exec -it roonserver /bin/bash
```

## License

Copyright (c) 2024 Noble Factor

This project is licensed under the MIT License. Roon Server software is subject to [Roon Labs Terms and Conditions](https://roon.app/en/termsandconditions).

## Support

For issues related to:

- **This Docker image**: Open an issue in this repository
- **Roon Server**: Visit [Roon Labs Support](https://roon.app/support)

## Acknowledgments

This project builds upon earlier work by Steef de Bruijn and the Roon Labs community.
