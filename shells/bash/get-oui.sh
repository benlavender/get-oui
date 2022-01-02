#!/bin/bash

# Query OUI code for a specified MAC address - By ben@benlavender.co.uk
# Requires access to Wireshark Foundation's GitLab on port 443
# Respects numerous MAC formats other than IEEE 802...

#Script settings:
URI='https://gitlab.com/wireshark/wireshark/-/raw/master/manuf'
ResponseCode='200'

# Confirms access to Wireshark Foundation's GitLab on https://gitlab.com/wireshark/wireshark/-/raw/master/manuf and translates the strings to a usable lookup:
if [ $(curl -L -s --HEAD -w "%{http_code}" -o /dev/null $URI) -eq $ResponseCode ]
    then
        echo 'Enter layer 2 address or OUI'
        read  OUI
        if [[ $OUI =~ ^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$ ]]
            then
                OUI=$(echo $OUI | head -c 8)
        elif [[ $OUI =~ ^([0-9A-Fa-f]{2}[.]){5}([0-9A-Fa-f]{2})$ ]] 
            then
                OUI=$(echo $OUI | head -c 8 | tr . :)
        elif [[ $OUI =~ ^([0-9A-Fa-f]{2}[-]){5}([0-9A-Fa-f]{2})$ ]] 
            then
                OUI=$(echo $OUI | head -c 8 | tr - :)
        elif [[ $OUI =~ ^([0-9A-Fa-f]{4}[-]){2}([0-9A-Fa-f]{4})$ ]] 
            then
                OUI=$(echo $OUI | tr -d - | sed 's/\(..\)\(..\)\(..\)\(..\)\(..\)/\1:\2:\3:\4:\5:/' | head -c 8)
        elif [[ $OUI =~ ^([0-9A-Fa-f]{4}[-]){1}([0-9A-Fa-f]{2})$ ]]
            then
                OUI=$(echo $OUI | tr -d - | sed 's/../&:/g;s/:$//')
        elif [[ $OUI =~ ^([0-9A-Fa-f]{2}[-]){2}([0-9A-Fa-f]{2})$ ]]
            then
                OUI=$(echo $OUI | tr - :)
        elif [[ $OUI =~ ^([0-9A-Fa-f]{2}[.]){2}([0-9A-Fa-f]{2})$ ]]
            then
                OUI=$(echo $OUI | tr . :)
        fi
        # Queries WS for the translated OUI value:
        if [[ $OUI =~ ^([0-9A-Fa-f]{2}[:]){2}([0-9A-Fa-f]{2})$ ]]
            then 
                curl -L -s $URI | grep -i $OUI
        else
            echo 'OUI value not valid for this operation'
        fi
    else 
        echo 'Unable to query repolist, check internet connection and proxy settings.'
fi