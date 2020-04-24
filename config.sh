#!/bin/bash

PTR="PDF"
lpadmin -p $PTR -v cups-pdf:/ -E -P /usr/share/ppd/cups-pdf/CUPS-PDF_opt.ppd
lpadmin -d $PTR
service cups restart
