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

  Default admin password is [here](https://github.com/thyrlian/AirPdfPrinter/blob/master/Dockerfile#L23)

* Run

  ```bash
  # Run a container with interactive shell (you'll have to start CUPS print server on your own)
  docker run -it -p 631:631 -p 49631:49631 -v $(pwd)/pdf:/root/PDF --name air-pdf-printer air-pdf-printer /bin/bash

  # Run a container in the background
  docker run -d -p 631:631 -p 49631:49631 -v $(pwd)/pdf:/root/PDF --name air-pdf-printer air-pdf-printer
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
