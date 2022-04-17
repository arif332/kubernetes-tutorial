**Title: K3s in Docker (K3d)**

**Table of Content**

- [1. Introduction](#1-introduction)
- [2. K3d Installation on MacOS ARM64](#2-k3d-installation-on-macos-arm64)
- [3. K3d Installation on Ubuntu (Intel CPU)](#3-k3d-installation-on-ubuntu-intel-cpu)
- [4. Use of K3d](#4-use-of-k3d)
  - [4.1. Single node k3s Cluster](#41-single-node-k3s-cluster)
  - [4.2. Multi-node K3s Cluster](#42-multi-node-k3s-cluster)
  - [4.3. K3d Operation Commands](#43-k3d-operation-commands)
- [5. References](#5-references)
- [6. Appendix](#6-appendix)
  - [6.1. Possible config parameters](#61-possible-config-parameters)



# 1. Introduction

Lightweight kubernetes (K3s) in Docker (K3d) is a community project. 


# 2. K3d Installation on MacOS ARM64
```bash
brew install k3d
```

# 3. K3d Installation on Ubuntu (Intel CPU)
```bash
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

# 4. Use of K3d

## 4.1. Single node k3s Cluster
Create a single node k3s cluster 
```bash
k3d cluster create mycluster

# check cluster info
kubectl cluster-info
kubectl get nodes
kubectl config get-contexts
```

## 4.2. Multi-node K3s Cluster
```bash
k3d cluster create mycluster1 --servers 1  --agents 1
```

## 4.3. K3d Operation Commands
List k3d cluster - 
```bash
k3d cluster list
```

Start/stop k3d cluster
```bash
k3d cluster stop [name]
k3d cluster stop -a

# start cluster
k3d cluster start [name]
k3d cluster start -a
```

Check k3d nodes
```bash
k3d node list
k3d node start NODE
k3d node stop NODE
```

# 5. References
- https://k3d.io
- https://k3d.io/v5.2.1/usage/configfile/
- https://github.com/rancher/k3d
- https://github.com/Homebrew/homebrew-core/blob/master/Formula/k3d.rb


# 6. Appendix

## 6.1. Possible config parameters
```yaml
# k3d configuration file, saved as e.g. /home/me/myk3dcluster.yaml
apiVersion: k3d.io/v1alpha3 # this will change in the future as we make everything more stable
kind: Simple # internally, we also have a Cluster config, which is not yet available externally
name: mycluster # name that you want to give to your cluster (will still be prefixed with `k3d-`)
servers: 1 # same as `--servers 1`
agents: 2 # same as `--agents 2`
kubeAPI: # same as `--api-port myhost.my.domain:6445` (where the name would resolve to 127.0.0.1)
  host: "myhost.my.domain" # important for the `server` setting in the kubeconfig
  hostIP: "127.0.0.1" # where the Kubernetes API will be listening on
  hostPort: "6445" # where the Kubernetes API listening port will be mapped to on your host system
image: rancher/k3s:v1.20.4-k3s1 # same as `--image rancher/k3s:v1.20.4-k3s1`
network: my-custom-net # same as `--network my-custom-net`
subnet: "172.28.0.0/16" # same as `--subnet 172.28.0.0/16`
token: superSecretToken # same as `--token superSecretToken`
volumes: # repeatable flags are represented as YAML lists
  - volume: /my/host/path:/path/in/node # same as `--volume '/my/host/path:/path/in/node@server:0;agent:*'`
    nodeFilters:
      - server:0
      - agent:*
ports:
  - port: 8080:80 # same as `--port '8080:80@loadbalancer'`
    nodeFilters:
      - loadbalancer
env:
  - envVar: bar=baz # same as `--env 'bar=baz@server:0'`
    nodeFilters:
      - server:0
registries: # define how registries should be created or used
  create: # creates a default registry to be used with the cluster; same as `--registry-create registry.localhost`
    name: registry.localhost
    host: "0.0.0.0"
    hostPort: "5000"
  use:
    - k3d-myotherregistry:5000 # some other k3d-managed registry; same as `--registry-use 'k3d-myotherregistry:5000'`
  config: | # define contents of the `registries.yaml` file (or reference a file); same as `--registry-config /path/to/config.yaml`
    mirrors:
      "my.company.registry":
        endpoint:
          - http://my.company.registry:5000
options:
  k3d: # k3d runtime settings
    wait: true # wait for cluster to be usable before returining; same as `--wait` (default: true)
    timeout: "60s" # wait timeout before aborting; same as `--timeout 60s`
    disableLoadbalancer: false # same as `--no-lb`
    disableImageVolume: false # same as `--no-image-volume`
    disableRollback: false # same as `--no-Rollback`
    loadbalancer:
      configOverrides:
        - settings.workerConnections=2048
  k3s: # options passed on to K3s itself
    extraArgs: # additional arguments passed to the `k3s server|agent` command; same as `--k3s-arg`
      - arg: --tls-san=my.host.domain
        nodeFilters:
          - server:*
    nodeLabels:
      - label: foo=bar # same as `--k3s-node-label 'foo=bar@agent:1'` -> this results in a Kubernetes node label
        nodeFilters:
          - agent:1
  kubeconfig:
    updateDefaultKubeconfig: true # add new cluster to your default Kubeconfig; same as `--kubeconfig-update-default` (default: true)
    switchCurrentContext: true # also set current-context to the new cluster's context; same as `--kubeconfig-switch-context` (default: true)
  runtime: # runtime (docker) specific options
    gpuRequest: all # same as `--gpus all`
    labels:
      - label: bar=baz # same as `--runtime-label 'bar=baz@agent:1'` -> this results in a runtime (docker) container label
        nodeFilters:
          - agent:1
```