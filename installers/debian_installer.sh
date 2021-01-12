#!/usr/bin/env bash

formatDataDisk ()
{
    # This script formats and mounts the drive on lun0 as /datadisk
    # This is azure specific?  
    DISK="/dev/disk/azure/scsi1/lun0"
    PARTITION="/dev/disk/azure/scsi1/lun0-part1"
    MOUNTPOINT="/datadisk"

    __log_debug "Partitioning the disk."
    echo "n
    p
    1
    t
    83
    w"| fdisk ${DISK}

    __log_debug "Waiting for the symbolic link to be created..."
    udevadm settle --exit-if-exists=$PARTITION

    __log_debug "Creating the filesystem."
    mkfs -j -t ext4 ${PARTITION}

    __log_debug "Updating fstab"
    LINE="${PARTITION}\t${MOUNTPOINT}\text4\tnoatime,nodiratime,nodev,noexec,nosuid\t1\t2"
    echo -e ${LINE} >> /etc/fstab

    __log_debug "Mounting the disk"
    mkdir -p $MOUNTPOINT
    mount -a

    __log_debug "Changing permissions"
    chown couchbase $MOUNTPOINT
    chgrp couchbase $MOUNTPOINT
}

adjustTCPKeepalive ()
{
# Azure public IPs have some odd keep alive behaviour
# A summary is available here https://docs.mongodb.org/ecosystem/platforms/windows-azure/
    
    __log_debug "Setting TCP keepalive..."
    #sysctl -w net.ipv4.tcp_keepalive_time=120 -q

    __log_debug "Setting TCP keepalive permanently..."
    echo "net.ipv4.tcp_keepalive_time = 120
    " >> /etc/sysctl.conf
    __log_debug "TCP keepalive setting changed."
}

turnOffTransparentHugepages ()
{
    __log_debug "Disabling Transparent Hugepages"
    cp "${SCRIPT_SOURCE}common/disableTHP.sh" /etc/init.d/disable-thp
    chmod 755 /etc/init.d/disable-thp
    service disable-thp start
    update-rc.d disable-thp defaults
    __log_debug "Transparent Hugepages have been disabled."
}

setSwappiness()
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

DEBIAN_OS_SUPPORTED_VERSIONS=("10" "9" "8")
DEBIAN_10_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
DEBIAN_9_SUPPORTED_VERSIONS=("5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4" "6.5.0" "6.5.1" "6.6.0" "6.6.1")
DEBIAN_8_SUPPORTED_VERSIONS=("5.0.1" "5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4" "6.5.0" "6.5.1" "6.6.0" "6.6.1")
OS_VERSION=$(awk 'NR==1{print $3}' /etc/issue)

# Prerequisite installation
# This is called by the main.sh to set up all necessary libaries
function __install_prerequisites() {
    __log_debug "Checking OS compatability"
    __log_debug "OS version is: ${OS_VERSION}"
    __log_debug "Supported Versions are: ${DEBIAN_OS_SUPPORTED_VERSIONS[*]}"
    supported=$(__elementIn "$OS_VERSION" "${DEBIAN_OS_SUPPORTED_VERSIONS[@]}")
    if [[ "$supported" == 1 ]]; then
        __log_error "This version of DEBIAN is not supported by Couchbase Server Enterprise Edition."
        exit 1
    fi
    __log_info "Installing prerequisites..."
    
    apt-get update > /dev/null
    # shellcheck disable=SC2034
    DEBIAN_FRONTEND=noninteractive
    __log_debug "Installing apt-utils"
    apt-get install --assume-yes apt-utils dialog  -qq > /dev/null
    __log_debug "apt-utils install complete"
    __log_debug "Installing python-httplib2"
    apt-get -y install python-httplib2 -qq > /dev/null
    __log_debug "python-httplib2 install complete"
    __log_debug "Installing jq"
    apt-get -y install jq -qq > /dev/null
    __log_debug "jq install complete"
    __log_debug "Installing net-tools"
    apt-get -y install net-tools -qq > /dev/null
    __log_debug "net-tools install complete"
    __log_debug "Installing wget"
    apt-get -y install wget -qq > /dev/null
    __log_debug "wget install complete."
    __log_debug "Installing lsb-base"
    apt-get -y install lsb-base -qq > /dev/null
    __log_debug "lsb_base install complete."
}

# Main Installer function.  This actually performs the download of the binaries
# This is called by main.sh for installation.
function __install_couchbase() {
    version=$1
    if [[ "$OS_VERSION" == "8" ]]; then
        version=$(__findClosestVersion "$1" "${DEBIAN_8_SUPPORTED_VERSIONS[@]}")
    fi
    if [[ "$OS_VERSION" == "9" ]]; then
        version=$(__findClosestVersion "$1" "${DEBIAN_9_SUPPORTED_VERSIONS[@]}")
    fi
    if [[ "$OS_VERSION" == "10" ]]; then
        version=$(__findClosestVersion "$1" "${DEBIAN_10_SUPPORTED_VERSIONS[@]}")
    fi
    tmp=$2
    __log_info "Installing Couchbase Server v${version}..."
    __log_debug "Downloading installer to: ${tmp}"
    wget -O "${tmp}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb" "http://packages.couchbase.com/releases/${version}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb" -q
    __log_debug "Download Complete.  Beginning Unpacking"
    if ! dpkg -i "${tmp}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb" > /dev/null; then
        __log_error "Error while installing ${tmp}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb"
        exit 1
    fi
    __log_debug "Unpacking complete.  Beginning Installation"
    apt-get update -qq > /dev/null
    apt-get -y install couchbase-server -qq > /dev/null

    #return the location of where the couchbase cli is installed
    export CLI_INSTALL_LOCATION="/opt/couchbase/bin"

}

# Post install this method is called to make changes to the system based on the environment being installed to
#  env can be AZURE, AWS, GCP, DOCKER, KUBERNETES, OTHER
function __configure_environment() {
    __log_debug "Configuring Environment"
    env=$1
    __log_debug "Setting up for environment: ${env}"
    if [[ "$env" == "AZURE" ]]; then
        formatDataDisk
    fi
    turnOffTransparentHugepages
    setSwappiness
    adjustTCPKeepalive
}