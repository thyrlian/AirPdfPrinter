# AirPdfPrinter

![headline](assets/AirPdfPrinter.png)

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-info-blue.svg)](https://hub.docker.com/r/thyrlian/air-pdf-printer)

You wanna print or save something as PDF on your iOS device?  Especially keeping those texts as they are, instead of being images.  Well, Apple's iDevices don't come with such a feature by default, but don't worry, we provide you a neat solution here - a virtual PDF AirPrint printer!

## Philosophy

To enable [AirPrint](https://support.apple.com/en-us/HT201311) of a printer, below requirements must be fulfilled, as described [here](https://wiki.debian.org/CUPSAirPrint).

  * The printer must be advertised with **Bonjour broadcasting**.

  * The printer must communicate with the client using **IPP** (Internet Printing Protocol).

## HOWTO

* **Build**

  ```bash
  # Assume you're in this project's root directory, where the Dockerfile is located
  docker build -t air-pdf-printer .

  # Build with argument, set your own admin password instead of the default one
  docker build --build-arg ADMIN_PASSWORD=<YourPassword> -t air-pdf-printer .

  # Or directly pull the image from Docker Hub
  docker pull thyrlian/air-pdf-printer
  ```

  The default admin username is `root`, and the default admin password is [here](https://github.com/thyrlian/AirPdfPrinter/blob/master/Dockerfile#L23).

* **Run**

  ```bash
  # Run a container with interactive shell (you'll have to start CUPS print server on your own)
  docker run --network=host -it -v $(pwd)/pdf:/root/PDF -v $(pwd)/cups-pdf:/var/spool/cups-pdf --name air-pdf-printer air-pdf-printer /bin/bash

  # Run a container in the background
  docker run --network=host -d -v $(pwd)/pdf:/root/PDF -v $(pwd)/cups-pdf:/var/spool/cups-pdf --name air-pdf-printer air-pdf-printer
  ```

* **Notes**

  * **Multi-Arch**: This Docker container would also work on ARM-based computer, you just need to build the Docker image properly.  Here I'm not gonna talk about Docker's experimental feature `buildx` for multiple architectures support, you can find more information [here](https://docs.docker.com/buildx/working-with-buildx/) and [here](https://docs.docker.com/docker-for-mac/multi-arch/) on your own.  In order to build for the appropriate CPU architecture, we can simply use the right base image in the Dockerfile.

    ```bash
    # Change base image to ARMv7 architecture
    sed -i.bak "s/FROM ubuntu:/FROM arm32v7\/ubuntu:/" Dockerfile && rm Dockerfile.bak

    # Change base image to x86_64 architecture
    sed -i.bak "s/FROM arm32v7\/ubuntu:/FROM ubuntu:/" Dockerfile && rm Dockerfile.bak
    ```

  * **Network**: With the option `--network=host` set, the container will use the Docker host network stack.  When using host network mode, it would discard published ports, thus we don't need to publish any port with the `run` command (e.g.: `-p 631:631 -p 5353:5353/udp`).  And in this way, we don't require [dbus](https://www.freedesktop.org/wiki/Software/dbus/) (a simple interprocess messaging system) package in the container.  However, the `dbus` service is still needed on the host machine (to check its status, you can run for example `systemctl status dbus` on Ubuntu), and even it is deactivated, it would be automatically triggered to active when `avahi-daemon` starts running.  For more information about Docker's network, please check [here](https://docs.docker.com/engine/reference/run/#network-settings) and [here](https://docs.docker.com/network/host/).  Please be aware, the host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac, Docker Desktop for Windows, as stated [here](https://docs.docker.com/network/network-tutorial-host/#prerequisites).

      * **Port conflict**: in case any required port on the host machine is already in use, Docker will fail to bind the container port to the host port, when this happens, you'll find a line in `/var/log/cups/error_log`: `Unable to open listen socket for address 0.0.0.0:631 - Address already in use`.  To debug and fix it:

        ```bash
        # Check ports in use on the host machine
        sudo lsof -i -P -n | grep LISTEN
        # Check if a specific port is in use on the host machine (e.g. port 631)
        sudo lsof -i:631
        
        # If port 631 is in use, it's highly likely that the CUPS service is running, then check the service status
        systemctl status cups
        # Stop the CUPS service
        systemctl stop cups
        # Furthermore, you may want to disable the CUPS service
        systemctl disable cups
        # It may happen that the CUPS service will be activated again after reboot, because it's required by another service, to check this
        systemctl --reverse list-dependencies cups.service
        # To disable the CUPS service, disregard anything else
        systemctl mask cups
        ```

  * **Port**: Apple is using UDP port 5353 to find capable services on your network via Bonjour automatically.  Even though mDNS discovery uses the predefined port UDP 5353, application-specific traffic for services like AirPlay may use dynamically selected port numbers.

    Port | TCP or UDP | Service or protocol name | RFC | Service name | Used by
    --- | --- | --- | --- | --- | ---
    5353 | UDP | Multicast DNS (MDNS) | 3927 | mdns | Bonjour, AirPlay, Home Sharing, Printer Discovery

* **Output**

  CUPS-PDF output directory are defined under **Path Settings** which is located at `/etc/cups/cups-pdf.conf`.  And the default path usually is: `/var/spool/cups-pdf/${USER}`

* **Troubleshoot**

  * CUPS logs directory: `/var/log/cups/`

  * Start Avahi daemon with verbose debug level: `avahi-daemon --debug`

* **Commands**

  ```bash
  # Run all init scripts, in alphabetical order, with the status command
  service --status-all

  # List units that systemd currently has in memory, with specified type and state
  systemctl list-units --type=service --state=active

  # Start CUPS service
  service cups start

  # Start Avahi mDNS/DNS-SD daemon
  service avahi-daemon start

  # Shows the server hostname and port.
  lpstat -H

  # Shows whether the CUPS server is running.
  lpstat -r

  # Shows all status information.
  lpstat -t

  # Shows all available destinations on the local network.
  lpstat -e

  # Shows the current default destination.
  lpstat -d

  # Display network connections, you need to have net-tools package installed
  netstat -ltup

  # Browse for all mDNS/DNS-SD services using the Avahi daemon and registered on the LAN
  avahi-browse -a -t

  # Find internet printing protocol printers
  ippfind
  ippfind --remote
  ```

* **Manage**

  Web Interface: http://[*IpAddressOfYourContainer*]:631/

* **Add Printer**

  * **macOS**: `System Preferences` -> `Printers & Scanners` -> `Add (+)` -> `IP`

    * **Address**: [*IpAddressOfYourContainer*]
    * **Protocol**: `Internet Printing Protocol - IPP`
    * **Queue**: `printers/PDF` (find the info here: http://[*IpAddressOfYourContainer*]:631/printers/)
    * **Name**: [*YourCall*]
    * **Use**: `Generic PostScript Printer`

    <a href="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20macOS.png" target="_blank"><img src="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20macOS.png" width="600"></a>

  * **iOS**

    <a href="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20iOS%20-%201.png" target="_blank"><img src="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20iOS%20-%201.png" width="250"></a>
    <a href="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20iOS%20-%202.png" target="_blank"><img src="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20iOS%20-%202.png" width="250"></a>
    <a href="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20iOS%20-%203.png" target="_blank"><img src="https://github.com/thyrlian/AirPdfPrinter/blob/master/assets/Add%20Printer%20-%20iOS%20-%203.png" width="250"></a>

## License

Copyright (c) 2020 Jing Li.  It is released under the [Apache License](http://www.apache.org/licenses/).  See the [LICENSE](https://raw.githubusercontent.com/thyrlian/AirPdfPrinter/master/LICENSE) file for details.

## Attribution

The [AirPrint-PDF.service](https://github.com/thyrlian/AirPdfPrinter/blob/master/AirPrint-PDF.service) static service XML file for Avahi is created via [airprint-generate](https://github.com/tjfontaine/airprint-generate) script.
