## Mailserver-Test

Mailserver-Test is a collection of shell scripts created to test a mailserver's setup. It includes a script to test an SMTP server and a script to test an IMAP server.

The Mailserver-Test scripts will connect to the mail-server, send their commands and get the response. The answers can then be compared to what you would expect based on your server configuration. The list of functions that can be checked includes:

*  SMTP
   * Connecting to SMTP via telnet on port 25
   * Connecting to SMTP via openssl on port 25 for StartTLS
   * Send email with SMTP Authentication, as well as without
   * RAW SMTP communucation is saved to a logfile
* IMAP
   * Connecting to IMAP via telnet on port 143
   * Connecting to IMAP via openssl on port 993 for SSL
   * Commands will EXAMINE and SELECT the INBOX and read the first available email
   * RAW IMAP comminucation is saved to a logfile
   

### Download & Installation

![image](http://www.tinned-software.net/images/icons/download.png) **[Download mailserver-test from Github](https://github.com/tinned-software/mailserver-test)**

To install the the script just download it from Github. There is no configuration file as all configuration is done via commandline.

### Description

The Mailserver-Test scripts are designed to connect to the mail-server to verify its configuration. These scripts do not aim to be full-featured email clients. 

The **smtp-test** script can be used to verify that emails cannot be sent without SMTP authentication to avoid an open relay. It can also be used to verify the correct setup of StartTLS on the SMTP server. Incoming emails to the SMTP server can be simulated as well by defining the recipient email to an email address locally handled by the mail server. It can be a handy little script to verify SMTP setup without typing the SMTP commands manually into a telnet session.

The **imap-test** script can be used to check the configuration of an IMAP server and its authentication settings. To make use of the full functionality of this script it is suggested that there should be an email in the INBOX as the script will fetch the first email from the IMAP server. It can be a handy little script to verify a server's setup without typing the IMAP commands manually into the telnet session.
