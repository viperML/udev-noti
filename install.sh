#!/bin/sh

BASEDIR=$(dirname "$0")

cp -i "$BASEDIR"/udev-noti.sh /usr/local/share/
cp -i "$BASEDIR"/udev-noti.rules /etc/udev/rules.d/10-udev-noti.rules
