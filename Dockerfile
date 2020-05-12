# ====================================================================== #
# APP - Air PDF Printer
# Virtual PDF AirPrint Printer Docker Image
# ====================================================================== #

# Base image
# ---------------------------------------------------------------------- #
FROM ubuntu:20.04

# Author
# ---------------------------------------------------------------------- #
LABEL maintainer "thyrlian@gmail.com"

# listen on ports
EXPOSE 631
EXPOSE 49631

# install CUPS packages
RUN apt update -y && apt upgrade -y && \
    apt install -y --no-install-recommends cups printer-driver-cups-pdf

# configure the CUPS scheduler
ARG ADMIN_PASSWORD=printer
RUN mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak && \
    chmod a-w /etc/cups/cupsd.conf.bak && \
    usermod -aG lpadmin root && \
    echo "root:${ADMIN_PASSWORD}" | chpasswd
ADD cupsd.conf /etc/cups/

# setup PDF printer
ADD config.sh /tmp/
RUN chmod +x /tmp/config.sh && /tmp/config.sh

# configure AirPrint
ADD AirPrint-PDF.service /etc/avahi/services/

# advertise AirPrint via Bonjour broadcast
RUN DEBIAN_FRONTEND=noninteractive && \
    apt install -y --no-install-recommends dbus avahi-daemon avahi-discover avahi-utils && \
    echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/apple.types && \
    echo "image/urf application/vnd.cups-postscript 66 pdftops" > /usr/share/cups/mime/local.convs && \
    echo "image/urf urf string(0,UNIRAST<00>)" > /usr/share/cups/mime/airprint.types && \
    echo "image/urf application/pdf 100 pdftoraster" > /usr/share/cups/mime/airprint.convs

# launch CUPS print server
CMD service cups start && service dbus start && service avahi-daemon start && tail -f /dev/null
