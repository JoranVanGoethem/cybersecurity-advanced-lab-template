#!/usr/bin/env sh

# Manual IPSec

## Clean all previous IPsec stuff

ip xfrm policy flush
ip xfrm state flush

## The first SA vars for the tunnel from homerouter to companyrouter

SPI7=0x007
ENCKEY7=0xFEDCBA9876543210FEDCBA9876543210

## Activate the tunnel from homerouter to companyrouter

### Define the SA (Security Association)

ip xfrm state add \
    src 192.168.62.253 \
    dst 192.168.62.42 \
    proto esp \
    spi ${SPI7} \
    mode tunnel \
    enc aes ${ENCKEY7}

### Set up the SP using this SA

#changed direction to in for company router
ip xfrm policy add \
    src 172.30.0.0/16 \
    dst 172.10.10.0/24 \
    dir in \
    tmpl \
    src 192.168.62.253 \
    dst 192.168.62.42 \
    proto esp \
    spi ${SPI7} \
    mode tunnel