#!/bin/bash
vAxwayCertStore="_path_to_axway_install_folder_here/apigateway/groups/group-*/conf/*/CertStore*.xml"
grep 'fval name="content"' $vAxwayCertStore 1>/tmp/certs.tmp
cat /tmp/certs.tmp | awk -F 'value>' '{print $2}'|awk -F '</' '{print "-----BEGIN CERTIFICATE-----\n"$1"\n-----END CERTIFICATE-----"}' | sed -e "s/\&\#xD\;\&\#xA\;/\\
/g" | sed -e "s/\&\#xA\;\&\#xD\;/\\
/g" | sed -e "s/\&\#xA\;/\\
/g" | sed -e "s/\&\#xD\;/\\
/g" > /tmp/certs.txt
rm -rf /tmp/certs.tmp
cat /tmp/certs.txt | tr ['\n']['\n'] '\n' > /tmp/temp.txt
mv /tmp/temp.txt /tmp/certs.txt
vLOOP="`cat /tmp/certs.txt`"
while [ "$vLOOP" ]
do
  vBEGIN="`grep -n 'BEGIN CERTIFICATE' /tmp/certs.txt|awk -F ':' '{print $1}'|head -1`"
  vEND="`grep -n 'END CERTIFICATE' /tmp/certs.txt|awk -F ':' '{print $1}'|head -1`"
  vNEXT=$[${vEND} + 1]
  cat /tmp/certs.txt|sed -n ${vBEGIN},${vEND}p>/tmp/cert.tmp
  cat /tmp/certs.txt|sed -n ${vNEXT},20000p>/tmp/remaining.tmp
  rm -rf /tmp/certs.txt
  mv /tmp/remaining.tmp /tmp/certs.txt
  vCERNAME="`openssl x509 -in /tmp/cert.tmp -noout -text|grep Subject|grep CN|awk -F 'CN=' '{print $2}'|awk -F '/emailAddress' '{print $1}'|tr ' ' '_'|tr '*' '_'`"
  vISCA="`openssl x509 -in /tmp/cert.tmp -noout -text|grep 'CA:TRUE'`"
  [[ ! "${vCERNAME}" ]] && vCERNAME="`date +%Y%m%d_%H%M%S`_cert" && cp -p /tmp/cert.tmp `date +%Y%m%d_%H%M%S`_no_CN.pem
  openssl x509 -in /tmp/cert.tmp -noout -text>${vCERNAME}.txt
  if [ "$vISCA" ]; then
    mv ${vCERNAME}.txt CA_${vCERNAME}.txt
    vCERNAME="CA_$vCERNAME"
  fi
  mv /tmp/cert.tmp ${vCERNAME}.pem
  echo -n "Saved cert: ${vCERNAME}.pem - "
  openssl x509 -in ${vCERNAME}.pem -noout -text |grep 'Not After'
  vLOOP="`cat /tmp/certs.txt`"
done
rm -rf /tmp/certs.txt
