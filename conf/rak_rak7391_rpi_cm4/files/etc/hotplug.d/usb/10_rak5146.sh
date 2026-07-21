#!/bin/sh

RAK5146_PRODUCT="483/5740/200"
SYMLINK="lora"

#logger -t DEBUG "hotplug usb: action='$ACTION' devicename='$DEVICENAME' devname='$DEVNAME' devpath='$DEVPATH' product='$PRODUCT' type='$TYPE' interface='$INTERFACE'"

if [ "${PRODUCT}" = "${RAK5146_PRODUCT}" ]; then 
    
    if [ "${ACTION}" = "bind" ]; then

        # Get DEVICE_NAME
        DEVICE_NAME=""
        if [ -e /sys/$DEVPATH/tty ]; then 
            DEVICE_NAME=$(ls /sys/$DEVPATH/tty)
        fi
        if [ "${DEVICE_NAME}" = "" ]; then 
            exit
        fi

        # Get symlink name
        INDEX=1
        while [ -e /dev/${SYMLINK}${INDEX} ]; do
            INDEX=$(( INDEX + 1 ))
        done

        # Link
        ln -s /dev/$DEVICE_NAME /dev/${SYMLINK}${INDEX}
        logger -t Hotplug symlink from /dev/$DEVICE_NAME to /dev/${SYMLINK}${INDEX} created

    fi

    if [ "${ACTION}" = "unbind" ]; then

        # Find broken symlink
        for LINK in $( find /dev/${SYMLINK}* -type l ); do
            test -e ${LINK}
            if [ $? -eq 1 ]; then
                rm ${LINK}
                logger -t Hotplug symlink ${LINK} removed
            fi
        done
        
    fi

fi