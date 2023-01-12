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
EXPOSE 5353/UDP

# install CUPS packages
RUN apt update -y && \
    apt install -y --no-install-recommends cups printer-driver-cups-pdf

# configure the CUPS scheduler
ARG ADMIN_PASSWORD=printer
RUN mv /etc/cups/cupsd.conf /etc/cups/cupsd.conf.bak && \
    chmod a-w /etc/cups/cupsd.conf.bak && \
    usermod -aG lpadmin root && \
    echo "root:${ADMIN_PASSWORD}" | chpasswd
ADD cupsd.conf /etc/cups/

# setup PDF printer
ADD --chmod=0755 config.sh /tmp/
RUN /tmp/config.sh

# configure AirPrint
ADD AirPrint-PDF.service /etc/avahi/services/

# advertise AirPrint via Bonjour broadcast
RUN DEBIAN_FRONTEND=noninteractive && \
    apt install -y --no-install-recommends avahi-daemon libnss-mdns && \
    echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/apple.types && \
    echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/local.types && \
    echo "image/urf application/vnd.cups-postscript 66 pdftops" > /usr/share/cups/mime/local.convs && \
    echo "image/urf urf string(0,UNIRAST<00>)" > /usr/share/cups/mime/airprint.types && \
    echo "image/urf application/pdf 100 pdftoraster" > /usr/share/cups/mime/airprint.convs && \
    sed -i "s/.*enable-dbus=.*/enable-dbus=no/g" /etc/avahi/avahi-daemon.conf

# launch CUPS print server
CMD service cups start && service avahi-daemon start && tail -f /dev/null
