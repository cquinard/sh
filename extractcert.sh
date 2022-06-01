#!/bin/bash
if [ "$1" == "" ]; then
    echo "ERROR: Specify a host:port to connect to."
else
    vCERTNAME="`echo $1 | tr ':' '_'`"
    echo QUIT | openssl s_client -showcerts -connect $1 2>error.log > /tmp/tempcert1.pem
    vVALIDATE="`grep "BEGIN CERTIFICATE" /tmp/tempcert1.pem`"
    if [ "$vVALIDATE" ]; then
        grep -A 300 "BEGIN CERTIFICATE" /tmp/tempcert1.pem >/tmp/tempcert2.pem
        grep -m 1 -B 300 "END CERTIFICATE" /tmp/tempcert2.pem > ${vCERTNAME}.pem
        echo "Cert saved to: ${vCERTNAME}.pem"
        openssl x509 -in ${vCERTNAME}.pem -noout -text -fingerprint
        if [ "$2" == "-c" ]; then
          openssl x509 -in ${vCERTNAME}.pem -noout -text -fingerprint |grep -A 1 'Serial Number:\|Issuer:\|Validity\|Not Before:\|Not After :\|Subject:\|SHA1 Fingerprint' |sed -e 's/    //g' |grep -v '\-\-\|Subject Public Key Info:' |pbcopy
        fi
    else
        echo "ERROR: Unable to connect to $1"
        cat error.log
    fi
fi
rm -rf error.log /tmp/tempcert1.pem /tmp/tempcert2.pem
