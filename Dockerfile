# ====================================================================== #
# APP - Air PDF Printer
# Virtual PDF AirPrint Printer Docker Image
# ====================================================================== #

# Base image
# ---------------------------------------------------------------------- #
FROM debian:buster

# Author
# ---------------------------------------------------------------------- #
LABEL maintainer "thyrlian@gmail.com"

# install CUPS packages
RUN apt update -y && apt upgrade -y && \
    apt install -y task-print-server printer-driver-cups-pdf

# listen on ports
EXPOSE 631
EXPOSE 49631
