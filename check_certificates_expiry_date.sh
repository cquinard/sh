#!/bin/bash
echo "$(date) Getting pem cert list 1/6..."
FILE="pem"; TYPE="pem"; find . -iname \*.$FILE -type f -exec openssl x509 -in {} -noout -inform $TYPE -subject -enddate \;  -exec echo file={} \; 2>/dev/null |grep 'file=\|subject=\|notAfter=' > /tmp/certlist.txt
echo "$(date) Getting der cert list 2/6..."
FILE="der"; TYPE="der"; find . -iname \*.$FILE -type f -exec openssl x509 -in {} -noout -inform $TYPE -subject -enddate \;  -exec echo file={} \; 2>/dev/null |grep 'file=\|subject=\|notAfter=' >> /tmp/certlist.txt
echo "$(date) Getting pem cert list 3/6..."
FILE="cer"; TYPE="pem"; find . -iname \*.$FILE -type f -exec openssl x509 -in {} -noout -inform $TYPE -subject -enddate \;  -exec echo file={} \; 2>/dev/null |grep 'file=\|subject=\|notAfter=' >> /tmp/certlist.txt
echo "$(date) Getting der cert list 4/6..."
FILE="cer"; TYPE="der"; find . -iname \*.$FILE -type f -exec openssl x509 -in {} -noout -inform $TYPE -subject -enddate \;  -exec echo file={} \; 2>/dev/null |grep 'file=\|subject=\|notAfter=' >> /tmp/certlist.txt
echo "$(date) Getting p7b cert list 5/6..."
FILE="p7b"; TYPE="pem"; find . -iname \*.$FILE -type f -exec openssl x509 -in {} -noout -inform $TYPE -subject -enddate \;  -exec echo file={} \; 2>/dev/null |grep 'file=\|subject=\|notAfter=' >> /tmp/certlist.txt
echo "$(date) Getting crt cert list 6/6..."
FILE="crt"; TYPE="pem"; find . -iname \*.$FILE -type f -exec openssl x509 -in {} -noout -inform $TYPE -subject -enddate \;  -exec echo file={} \; 2>/dev/null |grep 'file=\|subject=\|notAfter=' >> /tmp/certlist.txt

echo "$(date) Processing $(wc -l /tmp/certlist.txt) certs..."
vPOS="1"
echo > /tmp/finalcertlist.txt
echo "<html>
<head><title>Certificate expiration report</title></head>
<body>
<table border>
<tr><th>Expires on</th><th>Certificate Subject</th><th>Filename</th><th>Days left</th></tr>">output.htm
echo > output2.htm
while IFS= read -r line; do
  if [ "$vPOS" == "3" ]; then
    vFILENAME="$line"
    vPOS="0"
  fi
  if [ "$vPOS" == "2" ]; then
    vEXP="$line"
    vPOS="3"
  fi
  if [ "$vPOS" == "1" ]; then
    vCERT="$line"
    vPOS="2"
    vEXP=""
    vFILENAME=""
  fi
  if [ "$vPOS" == "0" ]; then
    vPOS="1"
  fi
  if [ "$vFILENAME" ]; then
    vEXP2="$(echo "$vEXP" | awk -F 'notAfter=' '{print $2}')"
    vEXP3="$(date --utc --date "$vEXP2" "+%s")"
    vEXP4="$(date --utc --date "$vEXP2" "+%Y%m%d")"
    vNOW="$(date --utc "+%s")"
    vSEC="$(echo "$vEXP3 - $vNOW" |bc)"
    vDAYS="$(echo "scale=0; $vSEC / (24*60*60)" |bc)"
    if [ "$vDAYS" -lt 0 ];then
      echo "$vEXP4 EXPIRED [$vCERT] [$vFILENAME]" >> /tmp/finalcertlist.txt
      echo "<tr><td>$vEXP4</td><td>$vCERT</td><td>$vFILENAME</td><td><b><font color=red>EXPIRED</font></b></td></tr>" >> output2.htm
    else
      echo "$vEXP4 [$vCERT] [$vFILENAME] - expires in $vDAYS days" >> /tmp/finalcertlist.txt
      echo "<tr><td>$vEXP4</td><td>$vCERT</td><td>$vFILENAME</td><td>$vDAYS</td></tr>" >> output2.htm
    fi
  fi
done < /tmp/certlist.txt
sed -i -e 's/subject=//g' output2.htm
sed -i -e 's/file=//g' output2.htm
cat output2.htm |sort |uniq >> output.htm
echo "</table>
Report generated: $(date)<BR>
</body>
</html>" >> output.htm

echo "$(date) Compiling final sorted list..."
cat /tmp/finalcertlist.txt |sort |uniq > output.txt
cat output.txt

rm -rf /tmp/certlist.txt /tmp/finalcertlist.txt
