#!/usr/bin/env bash

# Arguments:
# $1: version
# $2: vendor
# $3: target
# $4: subtarget
# $5: device
# $6: image
do_prepare_connect() {
  mkdir -p dist/$1/$2/$3/$4
  cp openwrt/bin/targets/$3/$4/connect-os-$1-$6-$5* dist/$1/$2/$3/$4
}

do_prepare_connect $1 rak bcm27xx bcm2711 rpi-cm4 rak7391
do_prepare_connect $1 rak bcm27xx bcm2711 rpi-cm4 rak7393
do_prepare_connect $1 rak bcm27xx bcm2711 rpi-cm4 rak7392
do_prepare_connect $1 rak bcm27xx bcm2712 rpi-cm5 rak7391
do_prepare_connect $1 rak bcm27xx bcm2712 rpi-cm5 rak7393
