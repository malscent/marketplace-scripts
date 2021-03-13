#!/usr/bin/env bash

set -eou pipefail
# These variables are utilized by logging
export DEBUG=0
export NO_COLOR=0
# get script directory to reference
# SCRIPT_SOURCE=${BASH_SOURCE[0]/%main.sh/}
# shellcheck disable=SC1091
# shellcheck source=common/loggers.sh
source './common/loggers.sh'
# shellcheck disable=SC1091
# shellcheck source=common/utils.sh
source './common/utils.sh'
# shellcheck disable=SC1091
# shellcheck source=common/help.sh
source './common/help.sh'
# shellcheck disable=SC1091
# shellcheck source=installers.installer.sh
source "./installers/installer.sh"

# Print header
print_header


#initialize help variable
HELP=0


#initialize variables
VERSION="6.6.1"
OS="UBUNTU"
AVAILABLE_OS_VALUES=("UBUNTU" "RHEL" "CENTOS" "DEBIAN" "AMAZON")
ENV="OTHER"
AVAILABLE_ENV_VALUES=("AZURE" "AWS" "GCP" "DOCKER" "KUBERNETES" "OTHER")
DEFAULT_USERNAME="couchbase"
DEFAULT_PASSWORD=$(__generate_random_string)
CB_USERNAME=$DEFAULT_USERNAME
CB_PASSWORD=$DEFAULT_PASSWORD
DAEMON=0
STARTUP=0
SYNC_GATEWAY=0
WAIT=0

# Here we're setting up a handler for unexpected errors during operations
function handle_exit() {
    __log_error "Error occurred during execution."
    exit 1
}

trap handle_exit SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM

# Process Command Line Arguments
# View Readme.md for explanations
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -v|--version)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        VERSION=$2
        shift 2
      else
        __log_error "Error: Argument for $1 is missing" >&2
        exit 1
      fi; #past argment
    ;;
    -os|--operating-system)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        useful=$(__elementIn "${2}" "${AVAILABLE_OS_VALUES[@]}")
        if [ "$useful" == 1 ]; then
            __log_error "Invalid OS Option choose one of:" "${AVAILABLE_OS_VALUES[@]}"
            exit 1
        fi
        OS=$(__toUpper "$2")
        shift 2
      else
        __log_error "Error: Argument for $1 is missing" >&2
        exit 1
      fi; #past argment
    ;;
    -ch|--cluster-host)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        CLUSTER_HOST=$2
        shift 2
      else
        __log_error "Error: Argument for $1 is missing" >&2
        exit 1
      fi; #past argment
    ;;
    -u|--user)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        CB_USERNAME=$2
        shift 2
      else
        __log_error "Error: Argument for $1 is missing" >&2
        exit 1
      fi; #past argment
    ;;
    -p|--password)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        CB_PASSWORD=$2
        shift 2
      else
        __log_error "Error: Argument for $1 is missing" >&2
        exit 1
      fi; #past argment
    ;;
    -g|--sync-gateway)
      SYNC_GATEWAY=1
      shift
    ;;
    -d|--debug)
    export DEBUG=1
    shift # past argument
    ;;
    -r|--run-continuously)
    DAEMON=1
    shift
    ;;    
    -s|--startup)
    STARTUP=1
    shift
    ;;
    -c|--no-color)
    export NO_COLOR=1
    shift
    ;;
    -e|--environment)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        useful=$(__elementIn "${2}" "${AVAILABLE_ENV_VALUES[@]}")
        if [ "$useful" == 1 ]; then
            __log_error "Invalid Environment Option choose one of:" "${AVAILABLE_ENV_VALUES[@]}"
            exit 1
        fi
        ENV=$(__toUpper "$2")
        shift 2
      else
        __log_error "Error: Argument for $1 is missing" >&2
        exit 1
      fi;
    ;;
    -w|--wait-nodes)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        WAIT=$2
        shift 2
      else
        __log_error "Error: Argument for $1 is missing" >&2
        exit 1
      fi; #past argment
    ;;
    -h|--help)
    HELP=1
    shift # past argument
    ;;
    *)    # unknown option
    shift # past argument
    ;;
esac
done

if [[ "$HELP" == 1 ]]; then
    print_help
    exit 0
fi


__log_info "Installing Couchbase Version ${VERSION}"
__log_info "Beginning execution"
__log_info "Installing on OS: ${OS}"
__log_info "Configuring for Environment: ${ENV}"


if [[ "$STARTUP" == "1" ]]; then
  __log_info "Checking for Couchbase Server Install"
  if [ -d "/opt/couchbase" ]; then
    __log_info "Couchbase is already installed.  Exiting"
    exit;
  fi
fi

#installing prerequisites from installer
__install_prerequisites "$OS" "$ENV" "$SYNC_GATEWAY"

#Getting information to determine whether this is the cluster host or not.  
LOCAL_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
HOST=$(hostname) || hostnamectl
__log_debug "Hostname:  ${HOST}"
__log_debug "Local IP: ${LOCAL_IP}"
DO_CLUSTER=0

# Check if host is cluster host, or local ip, or if the clusterhost contains the host for FQDN on GCP
if [[ "$CLUSTER_HOST" == "$HOST" ]] || [[ "$CLUSTER_HOST" == "$LOCAL_IP" ]] || [[ "$CLUSTER_HOST" == *"$HOST"* ]]; then
    __log_info "${CLUSTER_HOST} is host and is this machine"
    DO_CLUSTER=1
fi

if [[ "$SYNC_GATEWAY" == 1 ]]; then
    DO_CLUSTER=0
fi

__log_debug "The username is ${CB_USERNAME}"
__log_debug "The password is ${CB_PASSWORD}"

#Slap a warning if the user did not specify a username/passsword
if [[ "$CB_USERNAME" == "$DEFAULT_USERNAME" ]] && [[ "$CB_PASSWORD" == "$DEFAULT_PASSWORD" ]]; then
    __log_warning "Default user name and password detected.  You should immediately log into the web console and change the password on the couchbase user!"
fi



tmp_dir=$(mktemp -d)
__log_info "Temp directory will be ${tmp_dir}"


__install_couchbase "$VERSION" "${tmp_dir}" "$OS" "$SYNC_GATEWAY"


__log_debug "Adding an entry to /etc/hosts to simulate split brain DNS..."
echo "
# Simulate split brain DNS for Couchbase
127.0.0.1 ${HOST}
" >> /etc/hosts

__log_debug "Performing Post Installation Configuration"
__configure_environment "$ENV" "$OS" "$SYNC_GATEWAY"
__log_debug "Completed Post Installation Configuration"


if [[ "$SYNC_GATEWAY" == 0 ]]; then

  __log_debug "CLI Installed to:  ${CLI_INSTALL_LOCATION}"

  __log_debug "Prior to initialization.  Let's hit the UI and make sure we get a response"

  LOCAL_HOST_GET=$(wget --server-response --spider "http://localhost:8091/ui/index.html" 2>&1 | awk '/^  HTTP/{a=$2} END{print a}')
  __log_debug "LOCALHOST http://localhost:8091/ui/index.html: $LOCAL_HOST_GET"

  LOOPBACK_GET=$(wget  --server-response --spider "http://127.0.0.1:8091/ui/index.html" 2>&1 | awk '/^  HTTP/{a=$2} END{print a}')
  __log_debug "LOOPBACK http://127.0.0.1:8091/ui/index.html: $LOOPBACK_GET"

  HOSTNAME_GET=$(wget  --server-response --spider "http://${HOST}:8091/ui/index.html" 2>&1 | awk '/^  HTTP/{a=$2} END{print a}')
  __log_debug "HOST http://${HOST}:8091/ui/index.html:  $HOSTNAME_GET"

  IP_GET=$(wget --server-response --spider "http://${LOCAL_IP}:8091/ui/index.html" 2>&1 | awk '/^  HTTP/{a=$2} END{print a}')
  __log_debug "IP http://${LOCAL_IP}:8091/ui/index.html: $IP_GET"

  cd "${CLI_INSTALL_LOCATION}"

  __log_debug "Node intialization"
  resval=$(./couchbase-cli node-init \
    --cluster="${LOCAL_IP}" \
    --node-init-hostname="${LOCAL_IP}" \
    --node-init-data-path=/datadisk/data \
    --node-init-index-path=/datadisk/index \
    --username="$CB_USERNAME" \
    --password="$CB_PASSWORD") || __log_error "Error during Node Initialization"
  __log_debug "node-init result: \'$resval\'"

fi





if [[ $DO_CLUSTER == 1 ]]
then
  totalRAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  dataRAM=$((50 * totalRAM / 100000))
  indexRAM=$((15 * totalRAM / 100000))

  __log_debug "Running couchbase-cli cluster-init"
  result=$(./couchbase-cli cluster-init \
    --cluster="$CLUSTER_HOST" \
    --cluster-ramsize=$dataRAM \
    --cluster-index-ramsize=$indexRAM \
    --cluster-username="$CB_USERNAME" \
    --cluster-password="$CB_PASSWORD" \
    --services=data,index,query,fts) || __log_error "Error during Cluster Initialization"
__log_debug "cluster-init result: \'$result\'"
elif [[ $SYNC_GATEWAY == 0 ]]; 
then
  __log_debug "Running couchbase-cli server-add"
  output=""
  while [[ $output != "Server $LOCAL_IP:8091 added" && $output != *"Node is already part of cluster."* ]]
  do
    __log_debug "In server add loop"
    if ./couchbase-cli server-add \
      --cluster="$CLUSTER_HOST" \
      --username="$CB_USERNAME" \
      --password="$CB_PASSWORD" \
      --server-add="$LOCAL_IP" \
      --server-add-username="$CB_USERNAME" \
      --server-add-password="$CB_PASSWORD" \
      --services=data,index,query,fts; then
      output="Server $LOCAL_IP:8091 added"
    else
      __log_error "Error during Server Add"
    fi 
    __log_debug "server-add output \'$output\'"
    sleep 10
  done

  __log_debug "Running couchbase-cli rebalance"
  output=""
  while [[ ! $output =~ "SUCCESS" ]]
  do
    if ./couchbase-cli rebalance \
      --cluster="$CLUSTER_HOST" \
      --username="$CB_USERNAME" \
      --password="$CB_PASSWORD"; then
      output="SUCCESS"
      else
        __log_error "Error during Rebalance"
      fi
    __log_debug "rebalance output \'$output\'"
    sleep 10
  done
fi
__log_debug "Waiting for $WAIT nodes"

if [[ "$WAIT" -ne "0" && "$SYNC_GATEWAY" -ne "1" ]]; then
  __log_info "Beginning wait for cluster to have $WAIT nodes"
  healthy=0
  checks=0

  until [[ "$healthy" -eq "$WAIT" ]] || [[ "$checks" -ge "50" ]]; do
    __log_debug "Healthy node check - $healthy/$WAIT"
    healthy=$(wget -O -  \
                   --user "$CB_USERNAME" \
                   --password "$CB_PASSWORD" \
                   http://localhost:8091/pools/nodes \
                   -q \
                   | jq '[.nodes[] | select(.status == "healthy")] | length')
    (( checks += 1 ))
    sleep 3
  done
  __log_info "All nodes are healty - $healthy/$WAIT"
fi

__post_install_finalization "$ENV"
__log_info "Installation of Couchbase v${VERSION} is complete."



if [[ "$DAEMON" == 1 ]]; then
    __log_info "Going into daemon mode.  Will continue execution until cancelled."
    sleep infinity
fi