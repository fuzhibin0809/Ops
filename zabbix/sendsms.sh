#!/bin/bash

# 脚本的日志文件
LOGFILE="/tmp/SMS.log"
:>"$LOGFILE"
exec 1>"$LOGFILE"
exec 2>&1
 
MOBILE_NUMBER=$1    # 手机号码
SUBJECT=$2          # 短信主题
MESSAGE_UTF8=$3     # 短信内容
XXD="/usr/bin/xxd"
CURL="/usr/bin/curl"
TIMEOUT=5
# 短信内容要经过URL编码处理，除了下面这种方法，也可以用curl的--data-urlencode选项实现。
MESSAGE_ENCODE=$(echo -e "【】监控告警：\n#$SUBJECT#\n$MESSAGE_UTF8" | ${XXD} -ps | sed 's/\(..\)/%\1/g' | tr -d '\n')

# SMS API
URL="https://sms.yunpian.com/v2/sms/single_send.json"
 
# Send it
set -x
#${CURL} -s --connect-timeout ${TIMEOUT} "${URL}"
${CURL} -d "apikey=######################&mobile=${MOBILE_NUMBER}&text=${MESSAGE_ENCODE}" ${URL}
