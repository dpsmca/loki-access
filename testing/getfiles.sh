#!/usr/local/bin/bash

export GREP=/usr/local/bin/ggrep
export CURL=/usr/local/bin/curl
export AWK=/usr/local/bin/gawk
export HOST1="loki.mayo.edu"
export LOKIENV="dev"
export LOKIPORT="6080"
export HOSTURL="loki.mayo.edu"
export TGT="http://${HOSTURL}"
export AUTH="JSESSIONID"

export DEBUG="1"

T1="${LOKIENV,,}"
if [[ "${T1}" == "dev" ]]; then
  LOKIPORT="6080"
  TGT+=":${LOKIPORT}"
  AUTH+="_${LOKIPORT}"
elif [[ "${T1}" == "qa" ]]; then
  LOKIPORT="7080"
  TGT+=":${LOKIPORT}"
  AUTH+="_${LOKIPORT}"
elif [[ "${T1}" == "ctd" ]]; then
  LOKIPORT="9080"
  TGT+=":${LOKIPORT}"
  AUTH+="_${LOKIPORT}"
elif [[ "${T1}" == "prod" ]]; then
  LOKIPORT="80"
fi

export LOKIP1="wa07492"
export LOKIP2="I50tonicMutat10n"

function logDebug() {
  if [[ -n "${DEBUG}" && "${DEBUG}" == "1" ]]; then
    printf "%s\n" "${@}"
  fi
}

if [[ -z "${LOKIP1}" ]]; then
  read -r -p "Enter Loki username: " LOKIP1
fi

if [[ -z "${LOKIP2}" ]]; then
  read -r -s -p "Enter Loki password: " LOKIP2
fi

CMD1="${CURL} --cookie-jar cookie.txt -X POST -H \"Connection: keep-alive\" -d \"username=${LOKIP1}&password=${LOKIP2}\" \"${TGT}/login/security_check\""
logDebug "COMMAND 1: " "${CMD1}"
eval "${CMD1}"

SESSIONID="$(${GREP} -Po "${AUTH}\t\w+" cookie.txt | ${AWK} '{print $2}')"
logDebug "SESSION: " "${SESSIONID}"

if [[ -z "${SESSIONID}" ]]; then
  printf "ERROR\n=====\nCould not determine session ID\n"
  exit 1
fi

CMD1="${CURL} -b ${AUTH}=\"${SESSIONID}\" -c cookie.txt -X POST -H \"Connection: keep-alive\" -d \"e=test2%2Ftestdir1%2F%7Cwindows%2F&order=name\" -o directory_name.xml \"${TGT}/start/DirectoryService\""
logDebug "COMMAND 2: " "${CMD1}"
eval "${CMD1}"

CMD1="${CURL} -b ${AUTH}=\"${SESSIONID}\" -c cookie.txt -X POST -H \"Connection: keep-alive\" -d \"e=test2%2Ftestdir1%2F%7Cwindows%2F&order=date\" -o directory_date.xml \"${TGT}/start/DirectoryService\""
logDebug "COMMAND 3: " "${CMD1}"
eval "${CMD1}"

