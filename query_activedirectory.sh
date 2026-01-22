#!/bin/bash
# bash script to issue a lookup in active directory by username / sAMAccountName for macOS
if [ "$1" ]; then
	# ldapsearch -h domaincontroller.com -p 389 -o ldif-wrap=no -LLL -Q -b "DC=domain,DC=AD" "sAMAccountName=$1" |sort
	ldapsearch -a never -h domaincontroller.com -p 389 -D "your_full_DN_here" -w "password_here" -LLL  -o ldif-wrap=no -b "DC=domain,DC=AD" "sAMAccountName=$1" | sort
else
	echo "Specify sAMAccountName of user to query."
fi
