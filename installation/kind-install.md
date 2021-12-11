
Title: Kubernetes in Docker (Kind)


Table of Content

- [1. Introduction](#1-introduction)
- [2. Kind Installation in MacOS ARM64](#2-kind-installation-in-macos-arm64)
- [3. Kind Operation Command](#3-kind-operation-command)
- [4. References](#4-references)
- [5. Appendix](#5-appendix)
  - [5.1. Multi-node cluster](#51-multi-node-cluster)
  - [5.2. Control-plane HA](#52-control-plane-ha)

# 1. Introduction

Kind is a kubernetes installation in docker environment. 

# 2. Kind Installation in MacOS ARM64
```bash
# install kind package
brew install kind

# upgrade kind package
brew upgrade kind
```

# 3. Kind Operation Command
```bash
# create a cluster
kind create cluster

# with a name for the kind cluster
kind create cluster --name kind-2

# create a cluster with config file 
kind create cluster --config kind-example-config.yaml

# delete a cluster
kind delete cluster
```

Setup a kind cluster context
```bash
kubectl cluster-info --context kind-kind
```


# 4. References
- https://github.com/kubernetes-sigs/kind
- https://kind.sigs.k8s.io/docs/user/quick-start


# 5. Appendix

## 5.1. Multi-node cluster
```bash
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

## 5.2. Control-plane HA
```bash
# a cluster with 3 control-plane nodes and 3 workers
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
```
