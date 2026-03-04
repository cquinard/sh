#!/bin/bash
vPORT="80"
echo "$(date) Listening on port ${vPORT}." > pocket_web_server.log
while true; do
  nc -v -q 2 -N -l ${vPORT} < certificate_expiration_check/output.htm &> request.txt
  echo "$(date) Received request:" >> pocket_web_server.log
  cat request.txt >> pocket_web_server.log
  echo "$(date)"> request.txt
done
