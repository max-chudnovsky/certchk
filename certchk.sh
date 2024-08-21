#!/bin/bash
# script to get info about remote cert in parsable format
# written by Max Chudnovsky

### INIT
HST=$1
APPNAME=$(basename $0)

# usage message
usage(){
	echo "  Usage:"
	echo "    $APPNAME <host>"
}

# check parameter number
[ $# != 1 ] && {
	echo "$APPNAME: ERROR - Please provide host which you want to check as parameter"
	usage
	exit 1
}

# get certificate from remote site
OUT=$(openssl s_client -connect $HST:443 < /dev/null 2>&1 | openssl x509 -noout -text 2>&1)

# make sure we were able to get certificate
[[ "$OUT" == *"Could not read certificate"* ]] && {
	echo "$APPNAME,ERR,Could not read certificate from website."
	exit 1
}

### MAIN
# parse output
SUBJECT=$(echo "$OUT" | awk '/Subject: CN/{print $NF}')
ENCRYPTION=$(echo "$OUT" | awk '/Signature Algorithm:/{print $NF}' | head -1)
ISSUER=$(echo "$OUT" | awk -F, '/Issuer:/{print $2}' | sed 's/O =//' | sed "s/^[ \t]*//" | sed 's/,//g')
ISSUER_C=$(echo "$OUT" | awk -F, '/Issuer:/{print $1}'|awk '{print $NF}' | sed 's/,//g')
EXPIRY=$(echo "$OUT" | awk -F': ' '/Not After/{print $2}' | sed 's/,//g')

# output
echo "${1},$SUBJECT,$ISSUER,$ISSUER_C,$EXPIRY,$ENCRYPTION"
