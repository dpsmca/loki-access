#!/usr/local/bin/bash

export GREP=/usr/local/bin/ggrep
export CURL=/usr/local/bin/curl
export AWK=/usr/local/bin/awk
export TGT="loki.mayo.edu:6080"

if [[ -z "${LOKIP2}" ]]; then
  read -r -s -p "Enter Loki password: " LOKIP2
fi

${CURL} --cookie-jar cookie.txt -X POST -H "Connection: keep-alive" -d "username=m243189&password=${LOKIP2}" http://${TGT}/login/security_check

SESSIONID=$(${GREP} -Po "JSESSIONID_6080\t\w+" cookie.txt | ${AWK} '{print $2}')

if [[ -z "${SESSIONID}" ]]; then
  printf "ERROR\n=====\nCould not determine session ID\n"
  exit 1
fi

${CURL} -b JSESSIONID_6080=${SESSIONID} -c cookie.txt -X POST -H "Connection: keep-alive" -d "e=test2%2Ftestdir1%2F%7Cwindows%2F&order=name" -o directory_name.xml http://${TGT}/start/DirectoryService

${CURL} -b JSESSIONID_6080=${SESSIONID} -c cookie.txt -X POST -H "Connection: keep-alive" -d "e=test2%2Ftestdir1%2F%7Cwindows%2F&order=date" -o directory_date.xml http://${TGT}/start/DirectoryService

