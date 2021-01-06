#!/usr/bin/env bash

ERROR=1
DEBUG=0
INFO=1
WARNING=1

__LOG_COLOR_RED='\033[0;31m'
__LOG_NO_COLOR='\033[0m'
__LOG_COLOR_YELLOW='\033[0;33m'
__LOG_COLOR_GREY='\033[1;30m'
__LOG_TIMESTAMP_FORMAT="%m-%d-%YT%R:%S"

function __log_error() {
    NOW_ERROR=$(date +${__LOG_TIMESTAMP_FORMAT})
    if [[ "${ERROR}" == "1" ]]; then
        echo -e "${__LOG_COLOR_RED}[${NOW_ERROR}][ERROR]: $*${__LOG_NO_COLOR}"
    fi
}

function __log_debug() {
    NOW_DEBUG=$(date +${__LOG_TIMESTAMP_FORMAT})
    if [[ "${DEBUG}" == "1" ]]; then
        echo -e "${__LOG_COLOR_GREY}[${NOW_DEBUG}][DEBUG]: $*${__LOG_NO_COLOR}"
    fi
}

function __log_warning() {
    NOW_WARNING=$(date +${__LOG_TIMESTAMP_FORMAT})
    if [[ "${WARNING}" == "1" ]]; then
        echo -e "${__LOG_COLOR_YELLOW}[${NOW_WARNING}][WARN]: $*${__LOG_NO_COLOR}"
    fi
}

function __log_info() {
    NOW_INFO=$(date +${__LOG_TIMESTAMP_FORMAT})
    if [[ "${INFO}" == "1" ]]; then
        echo -e "${__LOG_NO_COLOR}[${NOW_INFO}][INFO]: $*${__LOG_NO_COLOR}"
    fi
}