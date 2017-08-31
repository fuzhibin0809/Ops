#!/bin/sh
#send mail by mail.rc
#$1, $2, $3 mean Recipient, Subject and Message
echo "$3" | /bin/mail -s "$2" $1
