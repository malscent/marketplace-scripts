# Couchbase Marketplace Installation Scripts

These scripts are intended for usage to install and cluster multiple VM's, containers, etc.

## Parameters

### ```-v|--version```

**Usage**:  ```./main.sh -v 6.6.1```

**Purpose**: Specifies the version of couchbase to install

### ```-os|--operating-system```
**Usage**: ```./main.sh -os UBUNTU```

**Purpose**:  Specifies the Operating System the script is being used to install to.  

**Options**: ```UBUNTU, MACOS, OSX, RHEL, CENTOS, DEBIAN```

### ```-ch|--cluster-host```

**Usage**: ```./main.sh -ch <CLUSTERHOST>```

**Purpose**: Specifies the cluster host name or ip address

### ```-u|--user```

**Usage**: ```./main.sh -u couchbase```

**Purpose**: Specifies the username to be used for both the couchbase install and the cluster join mechanism

### ```-p|--password```

**Usage**: ```./main.sh -p foo123!```

**Purpose**:  Specifies the password to be used for both the couchbase install and the cluster join mechanism

### ```-d|--debug```

**Usage**: ```./main.sh -d```

**Purpose**: Specifies that the script should be executed in debug mode, increasing output information to assist in debugging the script.

### ```-g|--sync-gateway```

**Usage**: ```./main.sh -g```

**Purpose**: Specifies that the script should install the Couchbase Sync Gateway instead of Couchbase Server

### ```-r|--run-continuously```

**Usage**: ```./main.sh -r```

**Purpose**: Specifies that the script should run forever to maintain container execution after script completes.  Used mainly for testing purposes.

### ```-e|--environment```

**Usage**: ```./main.sh -e AZURE```

**Purpose**: Specifies the environment that the script is being run in.  Allows installer to execute specific commands depending on where the script is being run.

**Options**:  ```AZURE, AWS, GCP, DOCKER, KUBERNETES, OTHER```

### ```-s|--startup```

**Usage**:  ```./main.sh -s```

**Purpose**: Specifies the install script to run in a mode that is intended to run on every boot of the server

### ```-h|--help```

**Usage**: ```./main.sh -```

**Purpose**:  Prints help regarding the parameters to pass to this script

## Build Containers for test

```
 docker build -t couchbase/ubuntu -f ./test_scripts/ubuntu/Dockerfile .
```

## Using Containers with arguments for testing

### Create Network
First you need to create a network to join your nodes to.
```
docker network create --driver bridge cb-net
```

### Clusterhost
Create a clusterhost 
```
docker run --privileged --hostname clusterhost --expose=8091 -ti --rm --network cb-net --name clusterhost  couchbase/ubuntu --version 6.6.1 -u couchbase -p foo123! -ch clusterhost -d -os UBUNTU -r
```

### Node
Create N nodes.
```
docker run --privileged --hostname nodehost1 -p 8091 -ti --network cb-net --name nodehost1  couchbase/ubuntu --version 6.6.1 -u couchbase -p foo123! -ch clusterhost -d -os UBUNTU -r -e DOCKER
```

## Using Docker Compose

To create a cluster for testing use:

```
docker-compose -f ./compose-files/<OS SPECIFIC FILE>.yml up
```

You can then reach the containers on http://localhost:8080 (RallyNode), http://localhost:8081 (NodeOne) and http://localhost:8082 (NodeTwo)

To take down the cluster:

```
docker-compose -f ./compose-files/<OS SPECIFIC FILE>.yml down
```