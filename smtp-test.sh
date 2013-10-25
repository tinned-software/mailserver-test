#!/bin/bash
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2013
version=0.1.0
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package email
#


# Configuration for the script
WAIT_TIME_LONG=2.5
WAIT_TIME=0.5

# How to mark the client and server content
CM="C:"
SM="S:"

# Initialize the variables
AUTH_ON="no-auth"
SMTP_SERVER=""
SENDER_EMAIL=""
RECIPIENT_EMAIL=""
CONN_TYPE="non-ssl"


#
# Parse all parameters
#
HELP=0
while [ $# -gt 0 ]; do
	case $1 in
		# General parameter
		-h|--help)
			HELP=1
			shift
			;;
		-v|--version)
			echo 
			echo "Copyright (c) 2013 Tinned-Software (Gerhard Steinbeis)"
			echo "License GNUv3: GNU General Public License version 3 <http://opensource.org/licenses/GPL-3.0>"
			echo 
			echo "`basename $0` version $version"
			echo
			exit 0
			;;

		# specific parameters
		auth)
			AUTH_ON=$1
			AUTH_USER=$2
			echo -n "Enter SMTP-Password: "
			read AUTH_PASS
			shift 2
			;;

		# specific parameters
		ssl)
			CONN_TYPE="ssl"
			shift
			;;

		# Unnamed parameter        
		*)
			if [[ "$SMTP_SERVER" == "" ]]; then
				SMTP_SERVER=$1
			else
				if [[ "$SENDER_EMAIL" == "" ]]; then
					SENDER_EMAIL=$1
				else
					if [[ "$RECIPIENT_EMAIL" == "" ]]; then
						RECIPIENT_EMAIL=$1
					fi
				fi
			fi
			shift
			;;
    esac
done

# Parameter check
if [[ "$SMTP_SERVER" == ""  ]]; then
	HELP=1
fi
if [[ "$SENDER_EMAIL" == ""  ]]; then
	HELP=1
fi
if [[ "$RECIPIENT_EMAIL" == ""  ]]; then
	HELP=1
fi

echo "SMTP-Server: $SMTP_SERVER"
echo "Sender-Email: $SENDER_EMAIL"
echo "Recipient-Email: $RECIPIENT_EMAIL"
echo "Connection: $CONN_TYPE"
if [[ "$AUTH_ON" == "auth" ]]; then
	echo "    Auth: YES"
	echo "    Auth-User: $AUTH_USER"
	echo "    Auth-Pass: *****"
	AUTH_EXT="_auth"
else
	echo "    Auth: NO"
	AUTH_EXT=""
fi
echo 

# check the connection type
if [[ "$CONN_TYPE" == "ssl" ]]; then
	SSL_EXT="_ssl"
fi
# Define extention for the logfile
LOG_EXT="${AUTH_EXT}${SSL_EXT}"


# show help message
if [ "$HELP" -eq "1" ]; then
	echo 
	echo "Copyright (c) 2013 Tinned-Software (Gerhard Steinbeis)"
	echo "License GNUv3: GNU General Public License version 3 <http://opensource.org/licenses/GPL-3.0>"
	echo 
	echo "This script is used to test the mail-server setup. It connects to the "
	echo "mail-server (optional with via SSL) and tries to send an email with "
	echo "the specified sender and recipient. The raw communication is "
	echo "afterwards shown and available in the log."
	echo 
	echo "Usage: `basename $0` [-hv] [auth username password] [ssl] smtp.domain.com sernder@domain.com recipient@example.com"
  	echo "  -h  --help         print this usage and exit"
	echo "  -v  --version      print version information and exit"
	echo "      auth           Use authentication with user-name and password"
	echo "      ssl            Connect via StartSSL to the mail server"
	echo 
	exit 1
fi

# Calculate the authentication hash
if [[ "$AUTH_ON" == "auth" ]]; then
	AUTH_HASH=`perl -MMIME::Base64 -e "print encode_base64(\"\000$AUTH_USER\000$AUTH_PASS\")"`
fi

# Generate the DATE info for the email header
DATE=`date`

echo -n "Starting the test ... "
echo -n >transaction$LOG_EXT.log

(sleep $WAIT_TIME_LONG
echo "$CM EHLO localhost" >>transaction$LOG_EXT.log &&
echo "EHLO localhost"
sleep $WAIT_TIME
if [[ "$AUTH_ON" == "auth" ]]; then
	echo "$CM AUTH PLAIN $AUTH_HASH" >>transaction$LOG_EXT.log &&
	echo "AUTH PLAIN $AUTH_HASH"
	sleep $WAIT_TIME
fi
echo "$CM MAIL FROM: <$SENDER_EMAIL>" >>transaction$LOG_EXT.log &&
echo "MAIL FROM: <$SENDER_EMAIL>"
sleep $WAIT_TIME
if [[ "$CONN_TYPE" == "ssl" ]]; then
	# RCPT TO in upper case causes a RENEGOTIATING, therefore it is lower case
	echo "$CM rcpt TO: <$RECIPIENT_EMAIL>" >>transaction$LOG_EXT.log &&
	echo "rcpt TO: <$RECIPIENT_EMAIL>"
else
	echo "$CM RCPT TO: <$RECIPIENT_EMAIL>" >>transaction$LOG_EXT.log &&
	echo "RCPT TO: <$RECIPIENT_EMAIL>"
fi
echo "$CM DATA" >>transaction$LOG_EXT.log &&
echo "DATA"
sleep $WAIT_TIME 
echo "$CM From: <$SENDER_EMAIL>
$CM To: <$RECIPIENT_EMAIL>
$CM Date: $DATE
$CM Subject: smtp-test email
$CM 
$CM This is a test mail sent from the smtp-test.
$CM To find out more about this script visit http://www.tinned-software.net/scripts_smtp-test/
$CM 
$CM Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse ut 
$CM mauris ut metus posuere ullamcorper et sed tellus. Morbi eleifend vel enim 
$CM vitae volutpat. Mauris tincidunt adipiscing lobortis. Quisque sed 
$CM adipiscing tortor, nec feugiat augue. Sed mi orci, scelerisque at sem 
$CM vitae, eleifend vulputate dolor. Fusce hendrerit risus at quam aliquam, sit 
$CM amet rutrum justo placerat. Etiam a magna et augue ullamcorper aliquam 
$CM accumsan sit amet est. Fusce facilisis pulvinar orci, in congue quam 
$CM venenatis ut. Proin ullamcorper dolor convallis, pulvinar dui ac, venenatis 
$CM nisi. Sed vitae nisi vitae nulla luctus porttitor. Sed tincidunt porta mi, 
$CM eget rhoncus dui aliquam. 
$CM .
$CM " >>transaction$LOG_EXT.log
echo "From: <$SENDER_EMAIL>
To: <$RECIPIENT_EMAIL>
Date: $DATE
Subject: smtp-test email

This is a test mail sent from the smtp-test.
To find out more about this script visit http://www.tinned-software.net/scripts_smtp-test/

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse ut 
mauris ut metus posuere ullamcorper et sed tellus. Morbi eleifend vel enim 
vitae volutpat. Mauris tincidunt adipiscing lobortis. Quisque sed 
adipiscing tortor, nec feugiat augue. Sed mi orci, scelerisque at sem 
vitae, eleifend vulputate dolor. Fusce hendrerit risus at quam aliquam, sit 
amet rutrum justo placerat. Etiam a magna et augue ullamcorper aliquam 
accumsan sit amet est. Fusce facilisis pulvinar orci, in congue quam 
venenatis ut. Proin ullamcorper dolor convallis, pulvinar dui ac, venenatis 
nisi. Sed vitae nisi vitae nulla luctus porttitor. Sed tincidunt porta mi, 
eget rhoncus dui aliquam. 
."
sleep $WAIT_TIME 
echo "$CM QUIT" >>transaction$LOG_EXT.log &&
echo "QUIT" 
) | 
if [[ "$CONN_TYPE" == "ssl" ]]; then
	openssl s_client -starttls smtp -crlf -connect $SMTP_SERVER:25 >>transaction$LOG_EXT.log 2>&1
else
	telnet $SMTP_SERVER 25 >>transaction$LOG_EXT.log 2>&1
fi



echo "FINISHED"
echo 
echo 
TRANSACTION=`cat transaction$LOG_EXT.log | sed -E "s/^([^$CM ].*)$/$SM &/"`
echo -n >transaction$LOG_EXT.log
if [[ "$CONN_TYPE" == "ssl" ]]; then
	echo "openssl s_client -starttls smtp -crlf -connect $SMTP_SERVER:25" >>transaction$LOG_EXT.log
else
	echo "telnet $SMTP_SERVER 25" >>transaction$LOG_EXT.log
fi
echo "$TRANSACTION" >>transaction$LOG_EXT.log
cat transaction$LOG_EXT.log
echo 
