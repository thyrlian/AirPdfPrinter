# ====================================================================== #
# APP - Air PDF Printer
# Virtual PDF AirPrint Printer Docker Image
# ====================================================================== #

# Base image
# ---------------------------------------------------------------------- #
FROM ubuntu:20.04

# Author
# ---------------------------------------------------------------------- #
LABEL org.opencontainers.version="v1.0.0"
LABEL org.opencontainers.image.authors "thyrlian@gmail.com"
LABEL org.opencontainers.image.url "https://github.com/thyrlian/AirPdfPrinter"
LABEL org.opencontainers.image.source "https://github.com/thyrlian/AirPdfPrinter"
LABEL org.opencontainers.image.title "PDF Airprinter"
LABEL org.opencontainers.image.description "A CUPS server that will save the print as a PDF"
LABEL org.opencontainers.image.licenses "Apache-2.0"


# listen on ports
EXPOSE 631
EXPOSE 5353/UDP

# install CUPS packages
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    cups \
    printer-driver-cups-pdf \
    avahi-daemon \
    libnss-mdns

# configure the CUPS scheduler
ARG ADMIN_PASSWORD=printer
ENV ADMIN_PASSWORD="${ADMIN_PASSWORD}"
RUN usermod -aG lpadmin root

COPY cupsd.conf /etc/cups/

# setup PDF printer
ADD config.sh /tmp/
RUN chmod +x /tmp/config.sh && /tmp/config.sh

# configure AirPrint
COPY AirPrint-PDF.service /etc/avahi/services/

# advertise AirPrint via Bonjour broadcast
RUN echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/apple.types && \
    echo "image/urf urf (0,UNIRAST)" > /usr/share/cups/mime/local.types && \
    echo "image/urf application/vnd.cups-postscript 66 pdftops" > /usr/share/cups/mime/local.convs && \
    echo "image/urf urf string(0,UNIRAST<00>)" > /usr/share/cups/mime/airprint.types && \
    echo "image/urf application/pdf 100 pdftoraster" > /usr/share/cups/mime/airprint.convs && \
    sed -i "s/.*enable-dbus=.*/enable-dbus=no/g" /etc/avahi/avahi-daemon.conf

# launch CUPS print server
CMD echo "root:${ADMIN_PASSWORD}" | chpasswd && service cups start && service avahi-daemon start && tail -f /dev/null

# these two labels will change every time the container is built
# put them at the end because of layer caching
ARG VCS_REF
LABEL org.opencontainers.image.revision "${VCS_REF}"

ARG BUILD_DATE
LABEL org.opencontainers.image.created "${BUILD_DATE}"