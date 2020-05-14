# AirPdfPrinter
Virtual PDF AirPrint printer

## HOWTO

* Build

  ```bash
  # Assume you're in this project's root directory, where the Dockerfile is located
  docker build -t air-pdf-printer .

  # Build with argument, set your own admin password instead of the default one
  docker build --build-arg ADMIN_PASSWORD=<YourPassword> -t air-pdf-printer .
  ```

  The default admin username is `root`, and the default admin password is [here](https://github.com/thyrlian/AirPdfPrinter/blob/master/Dockerfile#L23).

* Run

  ```bash
  # Run a container with interactive shell (you'll have to start CUPS print server on your own)
  docker run --network=host -it -p 631:631 -p 5353:5353/udp -v $(pwd)/pdf:/root/PDF -v $(pwd)/cups-pdf:/var/spool/cups-pdf --name air-pdf-printer air-pdf-printer /bin/bash

  # Run a container in the background
  docker run --network=host -d -p 631:631 -p 5353:5353/udp -v $(pwd)/pdf:/root/PDF -v $(pwd)/cups-pdf:/var/spool/cups-pdf --name air-pdf-printer air-pdf-printer
  ```

* Output

  CUPS-PDF output directory are defined under **Path Settings** which is located at `/etc/cups/cups-pdf.conf`.  And the default path usually is: `/var/spool/cups-pdf/${USER}`

* Troubleshoot

  Logs directory: `/var/log/cups/`

* Commands

  ```bash
  # Start CUPS service
  service cups start

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

## License

Copyright (c) 2020 Jing Li.  It is released under the [Apache License](http://www.apache.org/licenses/).  See the [LICENSE](https://raw.githubusercontent.com/thyrlian/AirPdfPrinter/master/LICENSE) file for details.

## Attribution

The [AirPrint-PDF.service](https://github.com/thyrlian/AirPdfPrinter/blob/master/AirPrint-PDF.service) static service XML file for Avahi is created via [airprint-generate](https://github.com/tjfontaine/airprint-generate) script.
