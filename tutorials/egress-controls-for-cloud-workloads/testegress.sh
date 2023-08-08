#!/usr/bin/bash

echo

# Check if we've been supplied an alternate test IP at commandline
if [ -n "$1" ]
then
  TESTIP="$1"
  echo "Using $TESTIP / testhost.aws (EIP of EC2 PublicTrafficHost) for some tests"
  echo
fi


#COLORS
reset='\033[0m'       # Text Reset
green='\033[0;92m'       # Green
red='\033[0;91m'
purple='\033[0;95m'      # Purple
cyan='\033[0;96m'
yellow='\033[0;93m'     # Yellow
orange='\033[0;33m'       # Yellow-Orangish

# COLORIZED MESSAGES
allowed_high="${red}ALLOWED${reset}"
allowed_medium="${orange}ALLOWED${reset}"
allowed_low="${yellow}ALLOWED${reset}"
allowed_green="${green}ALLOWED${reset}"
blocked="${green}BLOCKED${reset}"


function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}



## declare an array of example domains from TLD's that have high incidence of malicious domains
declare -a arr=("google.ru" "google.cn" "eth.xyz" "hello.cyou" "ourocean2022.pw" "fedne.ws" "multilanguage.gq" "nosara.surf" "www.cf" "www.ml")

# initialize variables for tracking outputs of loop
TOTAL=0
SUCCESS=0
FAILED=0

echo '*** R53 DNS FIREWALL CONTROLS ***'
## now loop through the above array
for i in "${arr[@]}"
do
    let TOTAL++
    RESULT=`dig +short +timeout=1 $i | tail -1`
    if valid_ip $RESULT; then
        let SUCCESS++
    else
        let FAILED++
    fi
done
if [ "$SUCCESS" -lt 1 ];then
    echo -e "Resolution of domains in Abused Top Level Domains - Resolved ${cyan}$SUCCESS/$TOTAL${reset} TLDs      $blocked"
    SUCCESS=1 #RESET FOR USE BELOW
elif [ "$SUCCESS" -lt 4 ]; then
    echo -e "Resolution of domains in Abused Top Level Domains - Resolved ${cyan}$SUCCESS/$TOTAL${reset} TLDs    $allowed_low"
     SUCCESS=0 #RESET FOR USE BELOW
elif [ "$SUCCESS" -lt 8 ]; then
    echo -e "Resolution of domains in Abused Top Level Domains - Resolved ${cyan}$SUCCESS/$TOTAL${reset} TLDs    $allowed_medium"
     SUCCESS=0 #RESET FOR USE BELOW
else
    echo -e "Resolution of domains in Abused Top Level Domains - Resolved ${cyan}$SUCCESS/$TOTAL${reset} TLDs     $allowed_high"
    SUCCESS=0 #RESET FOR USE BELOW
fi


# These are used in tracking PASS/FAIL Checks Below
TOTAL=1 #starting with 1 for TLD test above
# SUCCESS=0 #$SUCCESS initalized above based on test result
FAILED=0

# Test whether AWSManagedDomainsBotnetCommandandControl managed list is being blocked
let TOTAL++
RESULT=$(dig +short +timeout=1 controldomain1.botnetlist.firewall.route53resolver.us-east-1.amazonaws.com | tail -1)
if [ "$RESULT" == "1.2.3.4" ]; then
    echo -e "Resolution of domains on AWS Botnet list    $allowed_high"

else
    echo -e "Resolution of domains on AWS Botnet list    $blocked"
    let SUCCESS++
fi

# Test whether AWSManagedDomainsMalwareDomainList managed list is being blocked
let TOTAL++
RESULT=$(dig +short +timeout=1 controldomain1.malwarelist.firewall.route53resolver.us-east-1.amazonaws.com | tail -1)
if [ "$RESULT" == "1.2.3.4" ]; then
    echo -e "Resolution of domains on AWS Malware list    $allowed_high"

else
    echo -e "Resolution of domains on AWS Malware list    $blocked"
    let SUCCESS++
fi

# Test whether AWSManagedDomainsMalwaAWSManagedDomainsAggregateThreatList and AWSManagedDomainsAmazonGuardDutyThreatListreDomainList managed list is being blocked
let TOTAL++
RESULT=$(dig +short +timeout=1 controldomain1.aggregatelist.firewall.route53resolver.us-east-1.amazonaws.com | tail -1)
if [ "$RESULT" == "1.2.3.4" ]; then
    echo -e "Resolution of domains on AWS Aggreggate and GuardDuty Threat list    $allowed_high"

else
    echo -e "Resolution of domains on AWS Aggreggate and GuardDuty Threat list    $blocked"
    let SUCCESS++
fi

echo

echo '*** ANFW NETWORK CONTROLS - BYPASS OF R53RESOLVER ***'


# Test bypass of Route 53 Resolver by going to external public DNS server directly
let TOTAL++
RESULT=$(timeout 1 dig @8.8.8.8 +short +timeout=1 www.google.com | tail -1)
if valid_ip $RESULT; then
    echo -e "Resolution of DNS via Google DNS (8.8.8.8)    $allowed_high"

else
    echo -e "Resolution of DNS via Google DNS (8.8.8.8)     $blocked"
    let SUCCESS++
fi

# Test bypass of DNS logging/inspection with DNS over TLS (DOT) - REQUIRES kdig UTILITY BE INSTALLED
if ! command -v kdig &> /dev/null; then
    echo "Missing kdig to test DNS over TLS - to install type \"yum install knot-utils\" on Amazon Linux(may require sudo privileges)"
else
    let TOTAL++
    RESULT=$(kdig  @8.8.8.8 +short +tls-ca +tls-host=dns.google.com www.google.com +timeout=1  2> /dev/null | tail -1)
    if valid_ip $RESULT; then
        echo -e "Resolution of DNS over TLS (DoT)     $allowed_high"
    else
        echo -e "Resolution of DNS over TLS (DoT)     $blocked"
        let SUCCESS++
    fi
fi

# Test bypass of DNS logging/inspection with DNS over HTTPS (DoH)
let TOTAL++
RESULT=$(curl -H 'accept: application/dns-json' 'https://cloudflare-dns.com/dns-query?name=example.com&type=A' --max-time 2 2> /dev/null)
SUB='"AD":true'
if  [[ "$RESULT" == *"$SUB"* ]]; then
    echo -e "Resolution of DNS over HTTPS (DoH)     $allowed_high"
else
    echo -e "Resolution of DNS over HTTPS (DoH)     $blocked"
    let SUCCESS++
fi

echo

echo '*** ANFW NETWORK CONTROLS - ATTACK VECTORS ***'

# Test access of HTTP host with no fqdn in host header field (common in IOC for malware downloads)
let TOTAL++
if [ -v TESTIP ]; then
    RESULT=$(curl -s "$TESTIP" --connect-timeout 1 --max-time 1)
else
    RESULT=$(curl -s 3.237.234.244:80/e22.html --connect-timeout 1 --max-time 1)
fi
if  [ ! -z "$RESULT" ]; then
    echo -e "Communicate with IP (NO FQDN) over HTTP     $allowed_high"
else
    echo -e "Communicate with IP (NO FQDN) over HTTP     $blocked"
    let SUCCESS++
fi

# Test access of HTTPS with IP address instead of hostname in SNI field
#let TOTAL++
#RESULT=`curl -s https://1.1.1.1 --connect-timeout 1 --max-time 1`
#if  [ ! -z "$RESULT" ]; then
#    echo -e "Communicate with IP (NO FQDN) over HTTPS     $allowed_high"
#else
#    echo -e "Communicate with IP (NO FQDN) over HTTPS     $blocked"
#    let SUCCESS++
#fi

# Test protocol enforcement of HTTP by using HTTPS port 443 instead
let TOTAL++
if [ -v TESTIP ]; then
    RESULT=$(curl -s testhost.aws:443 --connect-timeout 1 --max-time 1)
else
    #RESULT=`curl -s portquiz.net:443 --connect-timeout 1 --max-time 1`
    RESULT=$(curl -s sectools.org:443 --connect-timeout 1 --max-time 1)
fi
if  [ ! -z "$RESULT" ]; then
    echo -e "HTTP using HTTPS/TLS port (443)     $allowed_high"
else
    echo -e "HTTP using HTTPS/TLS port (443)     $blocked"
    let SUCCESS++
fi

# Test access to port 21 FTP - more likely used for old school data exfil - but this should be blocked
#if ! command -v nc &> /dev/null; then
if ! command -v ftp &> /dev/null; then
    #echo "Missing netcat utility used to test FTP - to install type \"yum install nc\" on Amazon Linux(may require sudo privileges)"
    echo "Missing ftp utility used to test FTP - to install type \"yum install ftp\" on Amazon Linux(requires sudo privileges)"

else
    let TOTAL++
    if [ -v TESTIP ]; then
        #RESULT=$(nc "$TESTIP" 21 -i 1 -w 1 2>/dev/null)
        RESULT=$(echo -e "user badactor 5VXcbio8D3nsly\nbye" | timeout 1 ftp -inv testhost.aws 2>&1 | grep -q "Login successful" && echo "FTP login succeeded")

    else
        #RESULT=`curl -s portquiz.net:21 --connect-timeout 1 --max-time 1` #option for testing without netcat (nc)
        RESULT=$(nc ec2-50-16-152-75.compute-1.amazonaws.com 21 -i 1 2>/dev/null)
    fi
    if  [ ! -z "$RESULT" ]; then
        echo -e "FTP TCP Port 21 outbound     $allowed_high"
    else
        echo -e "FTP TCP Port 21 outbound     $blocked"
        let SUCCESS++
    fi
fi

# Test outbound access to LDAP port 1389 (port shows up routinely in log4j IOCs)
let TOTAL++
if [ -v TESTIP ]; then
    RESULT=$(curl -s testhost.aws:1389 --connect-timeout 1 --max-time 1)
else
    RESULT=$(curl -s portquiz.net:1389 --connect-timeout 1 --max-time 1)
fi
if  [ ! -z "$RESULT" ]; then
    echo -e "LDAP TCP Port 1389 outbound (log4j)     $allowed_high"
else
    echo -e "LDAP TCP Port 1389 outbound (log4j)   $blocked"
    let SUCCESS++
fi


# Test access of HTTP over a higher non-standard port - if this is allowed HTTP is likely allowed over any port
let TOTAL++
if [ -v TESTIP ]; then
    # RESULT=$(curl -s $TESTIP --connect-timeout 1 --max-time 1) # this test will get blocked by other rules because using direct to IP
    RESULT=$(curl -s testhost.aws:8080 --connect-timeout 1 --max-time 1)
else
    RESULT=$(curl -s ec2-34-204-251-246.compute-1.amazonaws.com:8080 --connect-timeout 1 --max-time 1)
fi
if  [ ! -z "$RESULT" ]; then
    echo -e "HTTP outbound over non-standard port (8080)     $allowed_high"
else
    echo -e "HTTP outbound over non-standard port (8080)     $blocked"
    let SUCCESS++
fi

# SSH Outbound over non-standard port - validates protocol detection
let TOTAL++
if [ -v TESTIP ]; then
    RESULT=$(timeout 1 ssh -v ech3ck@$TESTIP -p 2222 -o "StrictHostKeyChecking no" -o "ConnectTimeout 1" -o "UserKnownHostsFile=/dev/null" -o PasswordAuthentication=no exit 2>&1)
else
    RESULT=$(timeout 1 ssh -v ech3ck@3.237.234.244 -p 2222 -o "StrictHostKeyChecking no" -o "ConnectTimeout 1" -o "UserKnownHostsFile=/dev/null" -o PasswordAuthentication=no exit 2>&1)
fi
SUB="Permission denied"
if  [[ "$RESULT" == *"$SUB"*  ]]; then
    echo -e "SSH Outbound over non-standard port     $allowed_high"
else
    echo -e "SSH Outbound over non-standard port     $blocked"
    let SUCCESS++
fi


# SSH Outbound Test
let TOTAL++
if [ -v TESTIP ]; then
    RESULT=$(timeout 1 ssh -v ech3ck@$TESTIP -p 22 -o "StrictHostKeyChecking no" -o "ConnectTimeout 1" -o "UserKnownHostsFile=/dev/null" -o PasswordAuthentication=no exit 2>&1)
else
    RESULT=$(timeout 1 ssh -v ech3ck@3.237.234.244 -p 22 -o "StrictHostKeyChecking no" -o "ConnectTimeout 1" -o "UserKnownHostsFile=/dev/null" -o PasswordAuthentication=no exit 2>&1)
fi
SUB="Permission denied"
if  [[ "$RESULT" == *"$SUB"*  ]]; then
    echo -e "SSH Outbound to Remote Server over TCP 22     $allowed_high"
else
        echo -e "SSH Outbound to Remote Server TCP 22     $blocked"
        let SUCCESS++
fi



# Test outbound access over SMB port 445
if ! command -v smbclient &> /dev/null; then
    echo "Missing smbclient utility used to test SMB - to install type \"yum install samba-client\" on Amazon Linux(may require sudo privileges)"
else
    let TOTAL++
    if [ -v TESTIP ]; then
        RESULT=$(timeout 1 smbclient -t 1 "\\\\$TESTIP\\share_name" -U guest% 2>/dev/null)
    else
    #RESULT=`curl -s portquiz.net:445 --connect-timeout 1 --max-time 1` #option for testing without smbclient
    RESULT=$(timeout 1 smbclient -t 1 '\\3.237.234.244\tmp' -U guest% 2>/dev/null)
    fi
    SUB="NT_STATUS_LOGON_FAILURE"
    if  [[ "$RESULT" == *"$SUB"*  ]]; then
        echo -e "SMB TCP Port 445 outbound     $allowed_high"
    else
        echo -e "SMB TCP Port 445 outbound     $blocked"
        let SUCCESS++
    fi
fi


echo
echo -e "Your network controls blocked ${cyan}$SUCCESS${reset} of ${cyan}$TOTAL${reset} tests of egress filtering."
echo