#!/bin/bash
echo -e "AT+CGDCONT=1,\"IPV4V6\",\"wholesale\"\r" > /dev/ttyUSB2
echo -e "AT+QCFG=\"usbnet\",1\r" > /dev/ttyUSB2
echo -e "AT+CFUN=1,1\r" > /dev/ttyUSB2
```