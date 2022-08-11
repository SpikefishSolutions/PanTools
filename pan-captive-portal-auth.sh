# This script is meant to demonstrate how to use curl 
# via an https post to authenticate to a Palo Alto firewall
# Captive Portal url. This is for hosts that don't access to
# a full web browser, but need to authenticate to a Palo Alto 
# firewall to create a user to ip mapping via the Captive Portal.
# Note this script ignore ssl certifcate issues (--insecure).

# bail if mktemp isn't working.
pwfile=$(mktemp) || (echo failed to make tempfile ; exit 1)
# delete temp file on exit. This will prevent a tempfile from laying around with
# a password in it.
trap '{ rm "$pwfile"; }' EXIT

# read Captive Portal url
# Captive Portal (as of 10.1.x) with certificate installed and 
# authentication rule 0 uses this format.
# https://HostNameOrIP:6082/php/uid.php?vsys=1&rule=0
read -p "Enter Palo Alto Captive Portal URL: " pancaptiveportlurl
# read username for Captive Portal Auth
read -p "Enter Username: " panuser
# read password
echo -n "Enter password: "
# -s will disable prompt. :(
read -s panpassword
# add newline
echo

# securely write password to temp file. This is to prevent
# password from showing on ps -axwu output

# links $pwfile to file descriptor 3
# uses dd to write password to tempfile
# close file descriptor 3.
exec 3<> $pwfile
dd of=$pwfile <<<"$panpassword" >& /dev/null || exit 1
exec 3>&-

curl -s "$pancaptiveportlurl" \
        --data-urlencode 'inputStr=' \
        --data-urlencode 'escapeUser='$panuser \
        --data-urlencode 'preauthid=' \
        --data-urlencode 'user='$panuser \
        --data-urlencode 'passwd@'$pwfile \
        --data-urlencode 'ok=Login' \
        --insecure | egrep -q 'User Authenticated' >& /dev/null && echo Authentication Success || echo Authentication failed
