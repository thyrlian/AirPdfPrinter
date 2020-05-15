![headline](assets/AirPdfPrinter.png)

# AirPdfPrinter

You wanna print or save something as PDF on your iOS device?  Especially keeping those texts as they are, instead of being images.  Well, Apple's iDevices don't come with such a feature by default, but don't worry, we provide you a neat solution here - a virtual PDF AirPrint printer!

## HOWTO

* Build

  ```bash
  # Assume you're in this project's root directory, where the Dockerfile is located
  docker build -t air-pdf-printer .

  # Build with argument, set your own admin password instead of the default one
  docker build --build-arg ADMIN_PASSWORD=<YourPassword> -t air-pdf-printer .
  ```

  The default admin username is `root`, and the default admin password is [here](https://github.com/thyrlian/AirPdfPrinter/blob/master/Dockerfile#L25).

* Run

  ```bash
  # Run a container with interactive shell (you'll have to start CUPS print server on your own)
  docker run --network=host -it -v $(pwd)/pdf:/root/PDF -v $(pwd)/cups-pdf:/var/spool/cups-pdf --name air-pdf-printer air-pdf-printer /bin/bash

  # Run a container in the background
  docker run --network=host -d -v $(pwd)/pdf:/root/PDF -v $(pwd)/cups-pdf:/var/spool/cups-pdf --name air-pdf-printer air-pdf-printer
  ```

* Notes

  With the option `--network=host` set, the container will use the Docker host network stack.  When using host network mode, it would discard published ports, thus we don't need to publish any port with the `run` command (e.g.: `-p 631:631 -p 5353:5353/udp`).  And in this way, we don't require `dbus` (a simple interprocess messaging system) package in the container.  For more information, please check [here](https://docs.docker.com/engine/reference/run/#network-settings) and [here](https://docs.docker.com/network/host/).

* Output

  CUPS-PDF output directory are defined under **Path Settings** which is located at `/etc/cups/cups-pdf.conf`.  And the default path usually is: `/var/spool/cups-pdf/${USER}`

* Troubleshoot

  Logs directory: `/var/log/cups/`

* Commands

  ```bash
  # Run all init scripts, in alphabetical order, with the status command
  service --status-all

  # Start CUPS service
  service cups start

  # Start Avahi mDNS/DNS-SD daemon
  service avahi-daemon start

  # Start Avahi mDNS/DNS-SD daemon with verbose debug level
  avahi-daemon --debug

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

  # Find internet printing protocol printers
  ippfind
  ippfind --remote
  ```

* Manage

  Web Interface: http://[*IpAddressOfYourContainer*]:631/

* Add Printer

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
