# Mailserver-Test

The Mailserver-Test is a collection of shell scripts created to test the mailserver setup. It includes a script to test the SMTP server and a script to test the IMAP server.

The Mailserver-Test scripts aims to download files located in a specified directory. The list of functionality includes the following:

*  SMTP
   * Connecting to SMTP via telnet on port 25
   * Connecting to SMTP via openssl on port 25 for StartTLS
   * Send email with SMTP Authentication as well as without
   * RAW SMTP comminucation is saved to a logfile
* IMAP
   * Connecting to IMAP via telnet on port 143
   * Connecting to IMAP via openssl on port 993 for SSL
   * Commands will EXAMINE and SELECT the INBOX and read the first available email
   * RAW IMAP comminucation is saved to a logfile
   

## Download & Installation

[Download Download mailserver-test from Github](https://github.com/tinned-software/mailserver-test)

To install the the script just download it from Github. There is no configuration file as all configuration is done via commandline.

## Description

The Mailserver-Test scripts are designed to connect to the mail-server to verify its configuration. These scripts to not aim to be full featured email clients. 

The **smtp-test** script can be used to verify that emails cannot be sent without SMTP authentication to avoid an open relay. It can be used as well to verify the correct setup of StartTLS on the SMTP server. Incoming emails to the SMTP server can be simulated as well by defining the recipient email to an email address localy handled by the mail server. It can be a handy little script to verify the correct setup without typing the SMTP commands manually into the telnet session.

The **imap-test** script can be used to check the configuration of teh IMAP server and its authentication settings. To make use of the full functionality of this script it is suggested that there is an email in the INBOX as the script will fetch the first email from the IMAP server. It can be a handy little script to verify the correct setup without typing the IMAP commands manually into the telnet session.

