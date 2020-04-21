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

# listen on ports
EXPOSE 631
EXPOSE 49631

# install CUPS packages
RUN apt update -y && apt upgrade -y && \
    apt install -y task-print-server printer-driver-cups-pdf

# configure the CUPS scheduler
ARG ADMIN_PASSWORD=printer
RUN mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak && \
    chmod a-w /etc/cups/cupsd.conf.bak && \
    usermod -aG lpadmin root && \
    echo "root:${ADMIN_PASSWORD}" | chpasswd
ADD cupsd.conf /etc/cups/
