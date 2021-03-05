#!/usr/bin/env bash
CENTOS_OS_SUPPORTED_VERSIONS=("8" "7")
CENTOS_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
CENTOS_SUPPORTED_SYNC_GATEWAY_VERSIONS=("1.5.1" "1.5.2" "2.0.0" "2.1.0" "2.1.1" "2.1.2" "2.1.3" "2.5.0" "2.5.1" "2.6.0" "2.6.1" "2.7.0" "2.7.1" "2.7.2" "2.7.3" "2.7.4" "2.8.0")
DEBIAN_OS_SUPPORTED_VERSIONS=("10" "9" "8")
DEBIAN_10_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
DEBIAN_9_SUPPORTED_VERSIONS=("5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4" "6.5.0" "6.5.1" "6.6.0" "6.6.1")
DEBIAN_8_SUPPORTED_VERSIONS=("5.0.1" "5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4" "6.5.0" "6.5.1" "6.6.0" "6.6.1")
DEBIAN_SUPPORTED_SYNC_GATEWAY_VERSIONS=("1.5.1" "1.5.2" "2.0.0" "2.1.0" "2.1.1" "2.1.2" "2.1.3" "2.5.0" "2.5.1" "2.6.0" "2.6.1" "2.7.0" "2.7.1" "2.7.2" "2.7.3" "2.7.4" "2.8.0")
RHEL_OS_SUPPORTED_VERSIONS=("8" "7" "6")
RHEL_8_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
RHEL_7_SUPPORTED_VERSIONS=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
RHEL_6_SUPPORTED_VERSIONS=("5.0.1" "5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4")
RHEL_SUPPORTED_SYNC_GATEWAY_VERSIONS=("1.5.1" "1.5.2" "2.0.0" "2.1.0" "2.1.1" "2.1.2" "2.1.3" "2.5.0" "2.5.1" "2.6.0" "2.6.1" "2.7.0" "2.7.1" "2.7.2" "2.7.3" "2.7.4" "2.8.0")
UBUNTU_OS_SUPPORTED_VERSIONS=("14.04" "16.04" "18.04" "20.04")
UBUNTU_14_SUPPORTED_VERSIONS=("5.0.1" "5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1")
UBUNTU_16_SUPPORTED_VERSIONS=("5.0.1" "5.1.0" "5.1.1" "5.1.2" "5.1.3" "5.5.0" "5.5.1" "5.5.2" "5.5.3" "5.5.4" "5.5.5" "5.5.6" "6.0.0" "6.0.1" "6.0.2" "6.0.3" "6.0.4" "6.5.0" "6.5.1" "6.6.0" "6.6.1")
UBUNTU_18_SUPPORTED_VERSIONS=("6.0.1" "6.0.2" "6.0.3" "6.0.4" "6.5.0" "6.5.1" "6.6.0" "6.6.1" "7.0.0")
UBUNTU_20_SUPPORTED_VERSIONS=("7.0.0")
UBUNTU_SUPPORTED_SYNC_GATEWAY_VERSIONS=("1.5.1" "1.5.2" "2.0.0" "2.1.0" "2.1.1" "2.1.2" "2.1.3" "2.5.0" "2.5.1" "2.6.0" "2.6.1" "2.7.0" "2.7.1" "2.7.2" "2.7.3" "2.7.4" "2.8.0")

function __check_os_version() {
    __log_debug "Checking OS compatability"
    export OS_VERSION="UNKNOWN"
    SUPPORTED_VERSIONS=("UNKNOWN")
    os=$1
    if [[ "$os" == "CENTOS" ]]; then
        OS_VERSION=$(awk '/^VERSION_ID=/{print $1}' /etc/os-release | awk -F"=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')
        SUPPORTED_VERSIONS=("${CENTOS_OS_SUPPORTED_VERSIONS[*]}")
    elif [[ "$os" == "DEBIAN" ]]; then
        OS_VERSION=$(awk 'NR==1{print $3}' /etc/issue)
        SUPPORTED_VERSIONS=("${DEBIAN_OS_SUPPORTED_VERSIONS[*]}")
    elif [[ "$os" == "RHEL" ]]; then
        OS_VERSION=$(awk '/^VERSION_ID=/{print $1}' /etc/os-release | awk -F"=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')
        SUPPORTED_VERSIONS=("${RHEL_OS_SUPPORTED_VERSIONS[*]}")
    else
        OS_VERSION=$(awk 'NR==1{print $2}' /etc/issue | cut -c-5)
        SUPPORTED_VERSIONS=("${UBUNTU_OS_SUPPORTED_VERSIONS[@]}")
    fi
    __log_debug "OS version is: ${OS_VERSION}"
    __log_debug "Supported Versions are: ${SUPPORTED_VERSIONS[*]}"
    supported=$(__elementIn "$OS_VERSION" "${SUPPORTED_VERSIONS[@]}")
    if [[ "$supported" == 1 ]]; then
        __log_error "This version of ${os} is not supported by Couchbase Server Enterprise Edition."
        exit 1
    fi
}

function __centos_prerequisites() {
    yum update -q -y
    yum install epel-release jq net-tools python2 wget -q -y
    python2 -m pip -q install httplib2
}

function __ubuntu_prerequisites() {
    __log_debug "Updating package repositories"
    until apt-get update > /dev/null; do
        __log_error "Error performing package repository update"
        sleep 2
    done
    # shellcheck disable=SC2034
    DEBIAN_FRONTEND=noninteractive
    __log_debug "Installing Prequisites"
    until apt-get install --assume-yes apt-utils dialog python-httplib2 jq net-tools wget lsb-release  -qq > /dev/null; do
        __log_error "Error during pre-requisite installation"
        sleep 2
    done
    __log_debug "Prequisitie Installation complete"
}

function __rhel_prerequisites() {
    __centos_prerequisites
}

function __debian_prerequisites() {
    __ubuntu_prerequisites
}

function __install_prerequisites() {
    local os=$1
    __check_os_version "$os"
    __log_debug "Prequisites Installation"
    if [[ "$os" == "CENTOS" ]]; then
        __centos_prerequisites
    elif [[ "$os" == "DEBIAN" ]]; then
        __debian_prerequisites
    elif [[ "$os" == "RHEL" ]]; then
        __rhel_prerequisites
    else
        __ubuntu_prerequisites
    fi
    __log_debug "Prequisites Complete"
}
# https://docs.couchbase.com/server/current/install/thp-disable.html
turnOffTransparentHugepages ()
{
    local os=$1
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
    if [[ "$os" == "CENTOS"  || "$os" == "RHEL" ]]; then
        chkconfig --add disable-thp
    elif [[ "$os" == "DEBIAN" || "$os" == "UBUNTU" ]]; then
        update-rc.d disable-thp defaults
    fi
    __log_debug "Transparent Hugepages have been disabled."
}

adjustTCPKeepalive ()
{
# Azure public IPs have some odd keep alive behaviour
# A summary is available here https://docs.mongodb.org/ecosystem/platforms/windows-azure/
    if [[ "$2" == "AZURE" ]] && [[ "$1" == "UBUNTU" || "$1" == "DEBIAN" ]] ; then
        __log_debug "Setting TCP keepalive..."
        sysctl -w net.ipv4.tcp_keepalive_time=120 -q

        __log_debug "Setting TCP keepalive permanently..."
        echo "net.ipv4.tcp_keepalive_time = 120
        " >> /etc/sysctl.conf
        __log_debug "TCP keepalive setting changed."
    fi

}

formatDataDisk ()
{
    if [[ "$2" == "AZURE" ]]; then
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
    fi
}

setSwappiness()
{
    KERNEL_VERSION=$(uname -r)
    RET=$(__compareVersions "$KERNEL_VERSION" "3.5.0")
    SWAPPINESS=0
    if [[ "$RET" == "1" ]]; then
        SWAPPINESS=1
    fi
    __log_debug "Setting Swappiness to Zero"
    echo "
    # Required for Couchbase
    vm.swappiness = ${SWAPPINESS}
    " >> /etc/sysctl.conf

    sysctl vm.swappiness=${SWAPPINESS} -q

    __log_debug "Swappiness set to Zero"
}

# These are not exactly necessary.. But are here in case we need custom environment settings per OS
function __centos_environment() {
    __log_debug "Configuring CENTOS Specific Environment Settings"
}

function __debian_environment() {
    __log_debug "Configuring DEBIAN Specific Environment Settings"
}

function __ubuntu_environment() {
    __log_debug "Configuring UBUNTU Specific Environment Settings"
}

function __rhel_environment() {
    __log_debug "Configuring RHEL Specific Environment Settings"
}

function __configure_environment() {
    echo "Setting up Environment"
    local env=$1
    local os=$2
    __log_debug "Setting up for environment: ${env}"
    turnOffTransparentHugepages "$os"
    setSwappiness "$os"
    adjustTCPKeepalive "$os" "$env"
    formatDataDisk "$os" "$env"
    if [[ "$os" == "CENTOS" ]]; then
        __centos_environment "$env"
    elif [[ "$os" == "DEBIAN" ]]; then
        __debian_environment "$env"
    elif [[ "$os" == "RHEL" ]]; then
        __rhel_environment "$env"
    else
        __ubuntu_environment "$env"
    fi
}

function __install_syncgateway_centos() {
    local version=$1
    local tmp=$2
    __log_info "Installing Couchbase Sync Gateway Enterprise Edition v${version}"
    __log_debug "Downloading installer to: ${tmp}"
    wget -O "${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm" "https://packages.couchbase.com/releases/couchbase-sync-gateway/${version}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm" --quiet
    __log_debug "Download complete. Beginning Unpacking"
    if ! rpm -i "${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm" > /dev/null; then
        __log_error "Error while installing ${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.rpm"
        exit 1
    fi

}
function __install_syncgateway_rhel() {
    __install_syncgateway_centos "$1" "$2"
}
function __install_syncgateway_ubuntu() {
    local version=$1
    local tmp=$2
    __log_info "Installing Couchbase Sync Gateway Enterprise Edition v${version}"
    __log_debug "Downloading installer to: ${tmp}"
    wget -O "${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.deb" "https://packages.couchbase.com/releases/couchbase-sync-gateway/${version}/couchbase-sync-gateway-enterprise_${version}_x86_64.deb" --quiet
    __log_debug "Download complete. Beginning Unpacking"
    if ! dpkg -i "${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.deb" > /dev/null ; then
        __log_error "Error while installing ${tmp}/couchbase-sync-gateway-enterprise_${version}_x86_64.deb"
        exit 1
    fi
}
function __install_syncgateway_debian() {
    __install_syncgateway_ubuntu "$1" "$2"
}
function __install_syncgateway() {
    local version=$1
    local tmp=$2
    local os=$3
    __log_debug "Installing Sync Gateway"
    __log_debug "Setting up sync gateway user"
    useradd sync_gateway
    __log_debug "Creating sync_gateway home directory"
    mkdir -p /home/sync_gateway/
    chown sync_gateway:sync_gateway /home/sync_gateway
    if [[ "$os" == "CENTOS" ]]; then
        version=$(__findClosestVersion "$1" "${CENTOS_SUPPORTED_SYNC_GATEWAY_VERSIONS[@]}")
        __install_syncgateway_centos "$version" "$tmp"
    elif [[ "$os" == "DEBIAN" ]]; then
        version=$(__findClosestVersion "$1" "${DEBIAN_SUPPORTED_SYNC_GATEWAY_VERSIONS[@]}")
        __install_syncgateway_debian "$version" "$tmp"
    elif [[ "$os" == "RHEL" ]]; then
        version=$(__findClosestVersion "$1" "${RHEL_SUPPORTED_SYNC_GATEWAY_VERSIONS[@]}")
        __install_syncgateway_rhel "$version" "$tmp"
    else
        version=$(__findClosestVersion "$1" "${UBUNTU_SUPPORTED_SYNC_GATEWAY_VERSIONS[@]}")
        __install_syncgateway_ubuntu "$version" "$tmp"
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

    # Need to restart sync gateway service to load the changes
    if [[ "$os" == "CENTOS" ]]; then
        service sync_gateway stop
        service sync_gateway start
    else
        systemctl stop sync_gateway
        systemctl start sync_gateway
    fi
}

function __install_couchbase_centos() {
    local version=$1
    local tmp=$2
    __log_info "Installing Couchbase Server v${version}..."
    __log_debug "Downloading installer to: ${tmp}"
    curl --output "${tmp}/couchbase-release-1.0-x86_64.rpm" https://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-x86_64.rpm
    __log_debug "Download Complete.  Beginning Unpacking"
    rpm -i "${tmp}/couchbase-release-1.0-x86_64.rpm"
    __log_debug "Unpacking complete.  Beginning Installation"
    yum install "couchbase-server-${version}" -y -q
}

function __install_couchbase_rhel() {
    __install_couchbase_centos "$1" "$2"
}

function __install_couchbase_ubuntu() {
    local version=$1
    local tmp=$2
    __log_info "Installing Couchbase Server v${version}..."
    __log_debug "Downloading installer to: ${tmp}"
    wget -O "${tmp}/couchbase-server-enterprise_${version}-ubuntu${OS_VERSION}_amd64.deb" "http://packages.couchbase.com/releases/${version}/couchbase-server-enterprise_${version}-ubuntu${OS_VERSION}_amd64.deb" -q
    __log_debug "Download Complete.  Beginning Unpacking"
    until dpkg -i "${tmp}/couchbase-server-enterprise_${version}-ubuntu${OS_VERSION}_amd64.deb" > /dev/null; do
        __log_error "Error while installing ${tmp}/couchbase-server-enterprise_${version}-ubuntu${OS_VERSION}_amd64.deb"
        sleep 1
    done
    __log_debug "Unpacking complete.  Beginning Installation"
    until apt-get update -qq > /dev/null; do
        __log_error "Error updating package repositories"
        sleep 1
    done
    until apt-get -y install couchbase-server -qq > /dev/null; do
        __log_error "Error while installing ${tmp}/couchbase-server-enterprise_${version}-ubuntu${OS_VERSION}_amd64.deb"
        sleep 1
    done
}

function __install_couchbase_debian() {
    local version=$1
    local tmp=$2
    __log_info "Installing Couchbase Server v${version}..."
    __log_debug "Downloading installer to: ${tmp}"
    wget -O "${tmp}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb" "http://packages.couchbase.com/releases/${version}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb" -q
    __log_debug "Download Complete.  Beginning Unpacking"
    until dpkg -i "${tmp}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb" > /dev/null; do
        __log_error "Error while installing ${tmp}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb"
        sleep 1
    done
    __log_debug "Unpacking complete.  Beginning Installation"
    until apt-get update -qq > /dev/null; do
        __log_error "Error updating package repositories"
        sleep 1
    done
    until apt-get -y install couchbase-server -qq > /dev/null; do
        __log_error "Error while installing ${tmp}/couchbase-server-enterprise_${version}-debian${OS_VERSION}_amd64.deb"
        sleep 1
    done
}
function __install_couchbase() {
    local version=$1
    local tmp=$2
    local os=$3
    echo "Installing Couchbase"
        if [[ "$os" == "CENTOS" ]]; then
        version=$(__findClosestVersion "$1" "${CENTOS_SUPPORTED_VERSIONS[@]}")
        __install_couchbase_centos "$version" "$tmp"
    elif [[ "$os" == "DEBIAN" ]]; then
        if [[ "$OS_VERSION" == "8" ]]; then
            version=$(__findClosestVersion "$1" "${DEBIAN_8_SUPPORTED_VERSIONS[@]}")
        fi
        if [[ "$OS_VERSION" == "9" ]]; then
            version=$(__findClosestVersion "$1" "${DEBIAN_9_SUPPORTED_VERSIONS[@]}")
        fi
        if [[ "$OS_VERSION" == "10" ]]; then
            version=$(__findClosestVersion "$1" "${DEBIAN_10_SUPPORTED_VERSIONS[@]}")
        fi
        __install_couchbase_debian "$version" "$tmp"
    elif [[ "$os" == "RHEL" ]]; then
        if [[ "$OS_VERSION" == "8" ]]; then
            version=$(__findClosestVersion "$1" "${RHEL_8_SUPPORTED_VERSIONS[@]}")
        fi
        if [[ "$OS_VERSION" == "7" ]]; then
            version=$(__findClosestVersion "$1" "${RHEL_7_SUPPORTED_VERSIONS[@]}")
        fi
        if [[ "$OS_VERSION" == "6" ]]; then
            version=$(__findClosestVersion "$1" "${RHEL_6_SUPPORTED_VERSIONS[@]}")
        fi
        __install_couchbase_rhel "$version" "$tmp"
    else
        if [[ "$OS_VERSION" == "14.04" ]]; then
            version=$(__findClosestVersion "$1" "${UBUNTU_14_SUPPORTED_VERSIONS[@]}")
        fi
        if [[ "$OS_VERSION" == "16.04" ]]; then
            version=$(__findClosestVersion "$1" "${UBUNTU_16_SUPPORTED_VERSIONS[@]}")
        fi
        if [[ "$OS_VERSION" == "18.04" ]]; then
            version=$(__findClosestVersion "$1" "${UBUNTU_18_SUPPORTED_VERSIONS[@]}")
        fi
        if [[ "$OS_VERSION" == "20.04" ]]; then
            version=$(__findClosestVersion "$1" "${UBUNTU_20_SUPPORTED_VERSIONS[@]}")
        fi
        __install_couchbase_ubuntu "$version" "$tmp"
    fi

    export CLI_INSTALL_LOCATION="/opt/couchbase/bin"

}