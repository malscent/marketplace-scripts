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

CENTOS_OS_SUPPORTED_VERSIONS=("8" "7")
CENTOS_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
OS_VERSION=$(awk '/^VERSION_ID=/{print $1}' /etc/os-release | awk -F"=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')
# Prerequisite installation
# This is called by the main.sh to set up all necessary libaries
function __install_prerequisites() {
    __log_debug "Checking OS compatability"
    __log_debug "OS version is: ${OS_VERSION}"
    __log_debug "Supported Versions are: ${CENTOS_OS_SUPPORTED_VERSIONS[*]}"
    supported=$(__elementIn "$OS_VERSION" "${CENTOS_OS_SUPPORTED_VERSIONS[@]}")
    if [[ "$supported" == 1 ]]; then
        __log_error "This version of RHEL is not supported by Couchbase Server Enterprise Edition."
        exit 1
    fi
    __log_debug "Prequisites Installation"
    yum update -q -y
    yum install jq -q -y
    yum install epel-release -q -y
    yum install python2 -q -y
    yum install net-tools -q -y
    yum install wget -q -y
    python2 -m pip -q install httplib2
}

# Main Installer function.  This actually performs the download of the binaries
# This is called by main.sh for installation.
function __install_couchbase() {
    __log_debug "Installing Couchbase"
    version=$(__findClosestVersion "$1" "${CENTOS_SUPPORTED_VERSIONS[@]}")
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