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

# setup PDF printer
ADD config.sh /tmp/
RUN chmod +x /tmp/config.sh && /tmp/config.sh

# configure AirPrint
RUN wget https://raw.githubusercontent.com/tjfontaine/airprint-generate/master/airprint-generate.py && \
    chmod +x airprint-generate.py && \
    apt install -y python python-cups && \
    service cups start && \
    ./airprint-generate.py -d /etc/avahi/services/ && \
    service cups stop && \
    apt remove -y python python-cups && apt autoremove -y && \
    rm airprint-generate.py

# launch CUPS print server
CMD service cups start && tail -f /dev/null
