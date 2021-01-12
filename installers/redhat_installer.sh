#!/usr/bin/env bash

setSwappiness ()
{
    KERNAL_VERSION=$(uname -r)
    RET=$(__compareVersions "$KERNAL_VERSION" "3.5.0")
    SWAPPINESS=0
    if [[ "$RET" == "1" ]]; then
        SWAPPINESS=1
    fi
    __log_debug "Setting Swappiness to Zero"
    echo "
    # Required for Couchbase
    vm.swappiness = ${SWAPPINESS}
    " >> /etc/sysctl.conf
    __log_debug "Swappiness set to Zero"
}

turnOffTransparentHugepages ()
{
    __log_debug "Disabling Transparent Hugepages"
    cp "${SCRIPT_SOURCE}common/disableTHP.sh" /etc/init.d/disable-thp
    chmod 755 /etc/init.d/disable-thp
    service disable-thp start
    chkconfig --add disable-thp
    __log_debug "Transparent Hugepages have been disabled."
}

RHEL_OS_SUPPORTED_VERSIONS=("8" "7" "6")
RHEL_8_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
RHEL_7_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
RHEL_6_SUPPORTED_VERSIONS=("5.0.1" "5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4")
OS_VERSION=$(awk '/^VERSION_ID=/{print $1}' /etc/os-release | awk -F"=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')
OS_VERSION=${OS_VERSION:0:1}

# Prerequisite installation
# This is called by the main.sh to set up all necessary libaries
function __install_prerequisites() {
    __log_debug "Checking OS compatability"
    __log_debug "OS version is: ${OS_VERSION}"
    __log_debug "Supported Versions are: ${RHEL_OS_SUPPORTED_VERSIONS[*]}"
    supported=$(__elementIn "$OS_VERSION" "${RHEL_OS_SUPPORTED_VERSIONS[@]}")
    if [[ "$supported" == 1 ]]; then
        __log_error "This version of CENTOS is not supported by Couchbase Server Enterprise Edition."
        exit 1
    fi
    __log_debug "Prequisites Installation"
    yum update -q -y
    yum install jq -q -y
    yum install python2 -q -y
    yum install net-tools -q -y
    yum install wget -q -y
    yum install hostname -q -y
    yum install bind-utils -y -q
    python2 -m pip -q install httplib2
}

# Main Installer function.  This actually performs the download of the binaries
# This is called by main.sh for installation.
function __install_couchbase() {
    __log_debug "Installing Couchbase"
    version=$1
    if [[ "$OS_VERSION" == "8" ]]; then
        version=$(__findClosestVersion "$1" "${RHEL_8_SUPPORTED_VERSIONS[@]}")
    fi
    if [[ "$OS_VERSION" == "7" ]]; then
        version=$(__findClosestVersion "$1" "${RHEL_7_SUPPORTED_VERSIONS[@]}")
    fi
    if [[ "$OS_VERSION" == "6" ]]; then
        version=$(__findClosestVersion "$1" "${RHEL_6_SUPPORTED_VERSIONS[@]}")
    fi
    tmp=$2
    curl --output "${tmp}/couchbase-release-1.0-x86_64.rpm" https://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-x86_64.rpm
    rpm -i "${tmp}/couchbase-release-1.0-x86_64.rpm"
    yum install "couchbase-server-${version}" -y -q
    export CLI_INSTALL_LOCATION="/opt/couchbase/bin"
}

# Post install this method is called to make changes to the system based on the environment being installed to
#  env can be AZURE, AWS, GCP, DOCKER, KUBERNETES, OTHER
function __configure_environment() {
    __log_debug "Configuring Environment"
    local env=$1
    __log_debug "Setting up for environment: ${env}"
    echo "
    couchbase soft nproc 4096
    couchbase hard nproc 16384" > /etc/security/limits.d/91-couchbase.conf
    setSwappiness
}