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
    echo "#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-thp
# Required-Start:    \$local_fs
# Required-Stop:
# X-Start-Before:    couchbase-server
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable THP
# Description:       Disables transparent huge pages (THP) on boot, to improve
#                    Couchbase performance.
### END INIT INFO

case \$1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > \${thp_path}/enabled
    echo 'never' > \${thp_path}/defrag

    re='^[0-1]+$'
    if [[ \$(cat \${thp_path}/khugepaged/defrag) =~ \$re ]]
    then
      # RHEL 7
      echo 0  > \${thp_path}/khugepaged/defrag
    else
      # RHEL 6
      echo 'no' > \${thp_path}/khugepaged/defrag
    fi

    unset re
    unset thp_path
    ;;
esac
    " > /etc/init.d/disable-thp
    chmod 755 /etc/init.d/disable-thp
    service disable-thp start
    chkconfig --add disable-thp
    __log_debug "Transparent Hugepages have been disabled."
}

RHEL_OS_SUPPORTED_VERSIONS=("8" "7" "6")
RHEL_8_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
RHEL_7_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
RHEL_6_SUPPORTED_VERSIONS=("5.0.1" "5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4")
RHEL_SUPPORTED_SYNC_GATEWAY_VERSIONS=("1.5.1" "1.5.2" "2.0.0" "2.1.0" "2.1.1" "2.1.2" "2.1.3" "2.5.0" "2.5.1" "2.6.0" "2.6.1" "2.7.0" "2.7.1" "2.7.2" "2.7.3" "2.7.4" "2.8.0")

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

# Sync Gateway Installer,  For when the script is to be used to install sync gateway and not CBS
function __install_syncgateway() {
    version=$1
    tmp=$2
    version=$(__findClosestVersion "$1" "${RHEL_SUPPORTED_SYNC_GATEWAY_VERSIONS[@]}")
    echo "Setting up sync gateway user"
    useradd sync_gateway
    echo "Creating sync_gateway home directory"
    mkdir -p /home/sync_gateway/
    chown sync_gateway:sync_gateway /home/sync_gateway

    __log_info "Installing Couchbase Sync Gateway Enterprise Edition v${version}"
    __log_debug "Downloading installer to: ${tmp}"
    wget -O "${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm" https://packages.couchbase.com/releases/couchbase-sync-gateway/${version}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm --quiet
    __log_debug "Download complete. Beginning Unpacking"
    if ! rpm -i "${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm" > /dev/null; then
        __log_error "Error while installing ${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm"
        exit 1
    fi

    __log_info "Installation Complete. Configuring Couchbase Sync Gateway"

    file="/home/sync_gateway/sync_gateway.json"
    echo '
    {
    "interface": "0.0.0.0:4984",
    "adminInterface": "0.0.0.0:4985",
    "log": ["*"]
    }
    ' > ${file}
    chmod 755 ${file}
    chown sync_gateway ${file}
    chgrp sync_gateway ${file}

    # Need to restart to load the changes
    systemctl stop sync_gateway
    systemctl start sync_gateway
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