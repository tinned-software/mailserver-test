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
IMAP_SERVER=""
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
			fi
			shift
			;;
    esac
done

# Parameter check
if [[ "$SMTP_SERVER" == ""  ]]; then
	HELP=1
fi

# Parameter check
if [[ "$AUTH_ON" == "no-auth"  ]]; then
	HELP=1
fi

echo "IMAP-Server: $SMTP_SERVER"
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
	echo "This script is used to test the IMAP mail-server setup. It connects to the "
	echo "mail-server (optional with via SSL) and tries to check for emails. "
	echo "The raw communication is afterwards shown and available in the log."
	echo 
	echo "Usage: `basename $0` [-hv] auth username [ssl] smtp.domain.com"
  	echo "  -h  --help         print this usage and exit"
	echo "  -v  --version      print version information and exit"
	echo "      auth           Use authentication with user-name and password"
	echo "      ssl            Connect via StartSSL to the mail server"
	echo 
	exit 1
fi


# Generate the DATE info for the email header
DATE=`date`

echo -n "Starting the test ... "
echo -n >transaction$LOG_EXT.log

CC=1


(sleep $WAIT_TIME_LONG

echo "$CM a$CC LOGIN $AUTH_USER $AUTH_PASS" >>transaction$LOG_EXT.log &&
echo "a$CC LOGIN $AUTH_USER $AUTH_PASS"
CC=`expr $CC + 1`
sleep $WAIT_TIME

echo "$CM a$CC LIST \"\" \"*\"" >>transaction$LOG_EXT.log &&
echo "a$CC LIST \"\" \"*\""
CC=`expr $CC + 1`
sleep $WAIT_TIME

echo "$CM a$CC EXAMINE INBOX" >>transaction$LOG_EXT.log &&
echo "a$CC EXAMINE INBOX"
CC=`expr $CC + 1`
sleep $WAIT_TIME

echo "$CM a$CC SELECT INBOX" >>transaction$LOG_EXT.log &&
echo "a$CC SELECT INBOX"
CC=`expr $CC + 1`
sleep $WAIT_TIME

echo "$CM a$CC FETCH 1 BODY[]" >>transaction$LOG_EXT.log &&
echo "a$CC FETCH 1 BODY[]"
CC=`expr $CC + 1`
sleep $WAIT_TIME

echo "$CM a$CC LOGOUT" >>transaction$LOG_EXT.log &&
echo "a$CC LOGOUT"

) | 
if [[ "$CONN_TYPE" == "ssl" ]]; then
	openssl s_client -connect $SMTP_SERVER:993 >>transaction$LOG_EXT.log 2>&1
else
	telnet $SMTP_SERVER 143 >>transaction$LOG_EXT.log 2>&1
fi



echo "FINISHED"
echo 
echo 
TRANSACTION=`cat transaction$LOG_EXT.log | sed -E "/$CM /! s/^(.*)$/$SM &/"`
echo -n >transaction$LOG_EXT.log
if [[ "$CONN_TYPE" == "ssl" ]]; then
	echo "openssl s_client -connect $SMTP_SERVER:993" >>transaction$LOG_EXT.log
else
	echo "telnet $SMTP_SERVER 143" >>transaction$LOG_EXT.log
fi
echo "$TRANSACTION" >>transaction$LOG_EXT.log
cat transaction$LOG_EXT.log
echo 
