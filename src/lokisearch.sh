#!/usr/local/bin/bash

TERM="xterm-256color"

##################################################
# Pipeline Definition
##################################################
PIPELINE_NAME="LokiSearch"
PIPELINE_VERSION="1.00.00"

##################################################
# Local Variables
##################################################
INPUT_FILES_LIST=""
PARAMETER_SET=""
INPUT_FILES=()
DEBUG=0
HELP=0

##################################################
# Default Values
##################################################
SCRIPT=$( readlink -m $( type -p $0 ))
SCRIPT_DIR=$(dirname ${SCRIPT})
SCRIPT_NAME=$(basename ${SCRIPT})
SCRIPT_ROOT="$(dirname ${SCRIPT_DIR})"
REPO_HOME="$(dirname "$(dirname "${SCRIPT}")")"

SOURCE_DIR="${SCRIPT_ROOT}/src"
TEST_DIR="${SCRIPT_ROOT}/testing"
MAIN_SCRIPT="${SOURCE_DIR}/lokisearch.sh"
MAIN_RUNNER="${MAIN_SCRIPT}"
DEPLOYMENT_SOURCES="$(dirname ${SCRIPT_ROOT})"
DEPLOYED_VERSION_HOME="$(dirname ${DEPLOYMENT_SOURCES})"
DEPLOYED_VERSION_DIR="${DEPLOYED_VERSION_HOME}"
DEPLOYED_VERSION="$(basename "${DEPLOYED_VERSION_HOME}" )"
DEPLOYMENT_TOOLS="${DEPLOYED_VERSION_HOME}/tools"

##################################################
# Usage
##################################################

read -r -d '' DOCS <<DOCS
${PIPELINE_NAME} usage:

${SCRIPT_NAME} [options]

This script will submit a search to Loki.

OPTIONS:
    -i           [required]  Input raw file(s). If multiple files, provide a semicolon-separated list.
    -p           [required]  Parameter set to use for the search.
    -d           [optional]  Specifying this flag enables debug.
    -h           [optional]  Help (show this message)

EXAMPLES:
    # Submit a search using the "Amyloid" parameter set on file1.raw and file2.raw
    ${SCRIPT_NAME} -i "/odin/prod/testfiles/file1.raw;/odin/prod/testfiles/file2.raw" -p Amyloid

DOCS

##################################################
# Error logs
##################################################

read -r -d '' ERRCODES << ERRCODES
#error codes
#1  :  invalid input options
#10 :  file/directory does not exist
ERRCODES

##################################################
#Bash handling
##################################################

set -o errexit
set -o pipefail
set -o nounset

##################################################
# FUNCTIONS
##################################################
#We decided to inline these functions outside the standard pipeline commonFunctions flow based on the template install.sh used.
function logMsg () {
    echo -e "${1}"
    if [[ -f ${MAIN_LOG_FILE} ]]; then
        echo "[$(date +%Y-%m-%d'T'%H:%M:%S%z)] ${1}" | sed -r 's/\\n//'  >> "${MAIN_LOG_FILE}"
    fi
}
function runCmd () {
    logMsg "Running: ${1}"
    printf "\n"
    if [[ -f ${MAIN_LOG_FILE} ]]; then
        eval "${1}" | tee -a ${MAIN_LOG_FILE} 2>&1
    else
        eval "${1}" 2>&1
    fi
}


##################################################
#INPUT
##################################################

while getopts "i:p:dh" OPTION
do
    case $OPTION in
        i) INPUT_FILES_LIST="${OPTARG}" ;;
        p) PARAMETER_SET="${OPTARG}" ;;
        d) set -o xtrace ;;
        h) logMsg "\n${DOCS}\n" ; exit 0 ;;
        ?) logMsg "\n${DOCS}\n" ; exit 1 ;;
    esac
done

if [[ -z "${INPUT_FILES_LIST}" ]]; then
    logMsg "Error: no input files specified"
    exit 1
fi

mapfile -d ';' -t INPUT_FILES < <(echo "${INPUT_FILES_LIST}")

