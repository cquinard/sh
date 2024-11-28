#!/bin/bash
echo "<xml><body><data>Hello world!</data></body></xml>" > response.xml
vPORT="8888"
echo "$(date) Listening on port ${vPORT}."
while true; do
  nc -l ${vPORT} < response.xml > request.xml
  xmllint --format request.xml > formatted.xml 2>error.log
  if [ "$?" == "0" ]; then
    echo "$(date) Received request:"
    cat formatted.xml
    echo "$(date) Responded with:"
    xmllint --format response.xml
  else
    echo "$(date) ERROR: Invalid request."
    cat request.xml
    echo "***************************************************************************"
    cat error.log
    echo "***************************************************************************"
  fi
  echo -ne '\a'
done
