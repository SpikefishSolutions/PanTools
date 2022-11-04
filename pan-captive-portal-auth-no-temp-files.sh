# This script is meant to demonstrate how to use curl 
# via an https post to authenticate to a Palo Alto firewall
# Captive Portal url. This is for hosts that don't access to
# a full web browser, but need to authenticate to a Palo Alto 
# firewall to create a user to ip mapping via the Captive Portal.
# Note this script ignore ssl certifcate issues (--insecure).

# Note Note: This will echo the password on the screen
# and username/password will show up on ps output.
# I'm looking at you grandpa AIX system I had to deal with.

# read Captive Portal url
# Captive Portal (as of 10.1.x) with certificate installed and 
# authentication rule 0 uses this format.
# https://HostNameOrIP:6082/php/uid.php?vsys=1&rule=0
echo -n "Enter Palo Alto Captive Portal URL: "
read pancaptiveportalurl
# read username for Captive Portal Auth
echo -n "Enter Username: "
read panuser
# read password
echo -n "Enter password: "
read panpassword
# add newline
echo

curl -s "$pancaptiveportalurl" \
        --data-urlencode 'inputStr=' \
        --data-urlencode 'escapeUser='"$panuser" \
        --data-urlencode 'preauthid=' \
        --data-urlencode 'user='"$panuser" \
        --data-urlencode 'passwd='"$pwfile" \
        --data-urlencode 'ok=Login' \
        --insecure | egrep -q 'User Authenticated' > /dev/null 2>&1 && echo Authentication Success || echo Authentication failed
