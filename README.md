# AirPdfPrinter
Virtual PDF AirPrint printer

## HOWTO

* Build

  ```bash
  # Assume you're in this project's root directory, where the Dockerfile is located
  docker build -t air-pdf-printer .
  ```

* Play

  ```bash
  # Run a container with interactive shell
  docker run -it -p 631:631 -p 49631:49631 -v $(pwd)/pdf:/root/PDF --name air-pdf-printer air-pdf-printer /bin/bash
  ```
