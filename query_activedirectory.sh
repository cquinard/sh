#!/bin/bash
# bash script to issue a lookup in active directory by username / sAMAccountName for macOS
if [ "$1" ]; then
	ldapsearch -h domaincontroller.com -p 389 -o ldif-wrap=no -LLL -Q -b "DC=domain,DC=AD" "sAMAccountName=$1" |sort
else
	echo "Specify sAMAccountName of user to query."
fi
