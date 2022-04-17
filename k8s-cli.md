**TOC: Kubernetes Commands**

- [1. Introduction](#1-introduction)
- [2. Document History](#2-document-history)
- [3. Environment Setup](#3-environment-setup)
  - [3.1. Vim profile setup](#31-vim-profile-setup)
  - [3.2. Environment variable setup](#32-environment-variable-setup)
  - [3.3. Kubectl context and configuration](#33-kubectl-context-and-configuration)
- [4. K8s Imperative Command](#4-k8s-imperative-command)
  - [4.1. Create a busybox pod for testing](#41-create-a-busybox-pod-for-testing)
  - [4.2. Create a deployment and expose service](#42-create-a-deployment-and-expose-service)
  - [4.3. Activity on deployment](#43-activity-on-deployment)
  - [4.4. Add labels](#44-add-labels)
  - [4.5. Create Ingress Resource](#45-create-ingress-resource)
  - [4.6. Get events](#46-get-events)
  - [4.7. DNS record check](#47-dns-record-check)
  - [4.8. Fort Forward to Service/Pod](#48-fort-forward-to-servicepod)
- [5. Kubernetes Security](#5-kubernetes-security)
  - [5.1. Kube-bench: CIS bunchmark tool](#51-kube-bench-cis-bunchmark-tool)
  - [5.2. Image Vulnerability Scanning using Trivy](#52-image-vulnerability-scanning-using-trivy)
  - [5.3. OPA : Policy Definition](#53-opa--policy-definition)
  - [5.4. Using Container runtime (Sandboxes)](#54-using-container-runtime-sandboxes)
  - [5.5. Kernel Hardening tools - AppArmor](#55-kernel-hardening-tools---apparmor)
  - [5.6. Kernel Hardening tools - Seccomp](#56-kernel-hardening-tools---seccomp)
- [6. Supporting Utilities](#6-supporting-utilities)
  - [6.1. Curl command](#61-curl-command)
  - [6.2. Check SSL Certificate](#62-check-ssl-certificate)
  - [6.3. Create SSL Certificate](#63-create-ssl-certificate)
- [7. References](#7-references)
- [8. Appendix](#8-appendix)
  - [8.1. gVisor Installation](#81-gvisor-installation)
  - [8.2. Allow DNS traffic](#82-allow-dns-traffic)
  - [8.3. Deny all traffic](#83-deny-all-traffic)
  - [8.4. Allow all ingress traffic](#84-allow-all-ingress-traffic)

---

# 1. Introduction


# 2. Document History
```
2021-07-04 V1 "Initial k8s imperative command"
```

# 3. Environment Setup

## 3.1. Vim profile setup
```bash
cat <<EOF>~/.vimrc
set ts=2 sw=2 sts=2 et ai number colorcolumn=3,5,7,9
syntax on
colorscheme ron
EOF
# other options - paste, nopaste
# visual line(shift+v) / visual block(ctl+v) mode will help a lot to edit yaml config comfortably
```

## 3.2. Environment variable setup
```bash
cat <<EOF>kalias.sh
alias k="kubectl"
alias kgn="kubectl get node" 
alias aa='kubectl get all,sa,ep,sc,pv,pvc,cm,netpol'
alias kn='kubectl config set-context --current --namespace '
alias kcc='kubectl config get-contexts'
export do="--dry-run=client -o yaml" o="-o wide" y="-o yaml" l="--show-labels" r="--recursive"
source <(kubectl completion bash)
complete -F __start_kubectl k
EOF
source kalias.sh
```

## 3.3. Kubectl context and configuration
```bash
kubectl config view # Show Merged kubeconfig settings.

# use multiple kubeconfig files at the same time and view merged config
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2 

kubectl config view

# get the password for the e2e user
kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'

kubectl config view -o jsonpath='{.users[].name}'    # display the first user
kubectl config view -o jsonpath='{.users[*].name}'   # get a list of users
kubectl config get-contexts                          # display list of contexts 
kubectl config current-context                       # display the current-context
kubectl config use-context my-cluster-name           # set the default context to my-cluster-name

# add a new user to your kubeconf that supports basic auth
kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword

# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=ggckad-s2

# set a context utilizing a specific username and namespace.
kubectl config set-context gce --user=cluster-admin --namespace=foo \
  && kubectl config use-context gce

kubectl config unset users.foo                       # delete user foo

# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace) 
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

```

# 4. K8s Imperative Command

## 4.1. Create a busybox pod for testing
```bash
# buysbox pod with curl command
k run client --image=radial/busyboxplus:curl -- /bin/sh -c "sleep 3600"
# busybox pod with curl command and log write 
k run client --image=radial/busyboxplus:curl --command -- /bin/sh -c "while true; do echo hi; sleep 10; done"

#busybox with sh/bash
k exec -it client -- sh
k exec client -- curl ip

k run -it busybox --image=busybox:1.28 -- sh  # Run pod as interactive shell
k attach busybox -c busybox -i -t

# more debugging
k exec client -- nslookup client
```

## 4.2. Create a deployment and expose service
```bash
k create deployment nginx-deploy --image=nginx -r 3

#port=service port, target-port=pod port,
k expose deployment nginx-deploy --port=80 --target-port=8080 --name nginx-svc
```
## 4.3. Activity on deployment
```bash
# change image version and record will keep history of the given command
k set image deploy nginx-deploy nginx=nginx:1.16.1 --record

# edit deployment 
k edit deploy nginx-deployment

# make zero replication 
k scale deploy nginx-deploy --replicas=0 

# restart a deployment
k rollout restart deploy nginx-deploy

# check update history, .spec.revisionHistoryLimit (default is 10)
k rollout history deploy nginx-deploy

# roolout status
k rollout status deploy apparmor 

#roll-back
k rollout undo deploy apparmor 
```

## 4.4. Add labels
```bash
k label ns nptest project=test
k label pods client role=client
```

## 4.5. Create Ingress Resource 
```bash
# exact match with a tls certificate, need to know svc name and port of svc
k create ingress simple --rule="foo.com/bar=svc1:8080,tls=my-cert"

# any match with a tls, need to know svc name and port of svc
k create ingress simple --rule="foo.com/*=svc1:8080,tls=my-cert"
```
## 4.6. Get events
```bash
k get ev -w

# get event by timestamp
k -n ns get events --sort-by='{.metadata.creationTimestamp}'
```

## 4.7. DNS record check
```bash
k apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
k exec -it dnsutils -- nslookup kubernetes.default
k exec client -- cat /etc/resolv.conf
k exec client -- nslookup pod-name

#dns sever check
k logs -n kube-system -l k8s-app=kube-dns
```

## 4.8. Fort Forward to Service/Pod

```bash
# listen on 0.0.0.0:9021 which allow to connect from external host
k port-forward controlcenter-0 9021:9021 --address='0.0.0.0'
```







# 5. Kubernetes Security

## 5.1. Kube-bench: CIS bunchmark tool
```bash
# install kube-bench as a job
k apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-master.yaml
k apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-node.yaml
k get pods
k logs <Control Plane Job Pod name> > kube-bench-results-control-plane.log

k get jobs
k delete job kube-bench-master

# manually install kube-bench tool
# curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.6.2/kube-bench_0.6.2_linux_amd64.tar.gz -o kube-bench_0.6.2_linux_amd64.tar.gz
# tar -xvf kube-bench_0.6.2_linux_amd64.tar.gz

./kube-bench --config-dir cfg
./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml
``` 


## 5.2. Image Vulnerability Scanning using Trivy
```bash
# install trivy after adding repo to apt
sudo apt-get install trivy

# All images running in namespace: default, grouped by Pod
k get pods -n default --output=custom-columns="NAME:.metadata.name,IMAGE:.spec.containers[*].image"

# check high and critical vulnerability, command argument will vary depends on the version of trivy
trivy nginx | egrep -i "HIGH|critical"
trivy image nginx | egrep -i "HIGH|critical"
```

## 5.3. OPA : Policy Definition
```bash
# get Custom Resource Definitions (CRDs)
k get crd

k get constrainttemplate <template-name>
k describe constrainttemplate <template-name>

# to modify OPA policy 
k edit constrainttemplate <template-name> 
```

## 5.4. Using Container runtime (Sandboxes)
Create a RuntimeClass and use that while creating pods. Follow appendix for the gVisor installation. 
```bash
cat <<EOF>>runtimesc.yaml
apiVersion: node.k8s.io/v1  
kind: RuntimeClass
metadata:
  name: myclass  
handler: runsc 
EOF
k create -f runtimesc.yaml

# pod definition
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  runtimeClassName: myclass
...

# check logs and compare
kubectl exec non-sandbox-pod -- dmesg 
```

##  5.5. Kernel Hardening tools - AppArmor
```bash
# install apparmor util 
apt-get install apparmor-util

# profile location: /etc/apparmor.d

# generate docker-nginx profile by below command 
apparmor_parser /etc/apparmor.d/docker-nginx

# verify profile status
aa-status

# now use apparmor profile in pod definition file to enforce profile
k run secure --image=nginx $do > secure.yaml
vim secure.yaml # add pod annotation key and value, as per velow format
# container.apparmor.security.beta.kubernetes.io/<container_name>: localhost/<profile_name>

k -f secure.yaml create
```

## 5.6. Kernel Hardening tools - Seccomp
```bash
# seccomp's profile location is define in kubelet config using --seccomp-profile-root 
# --seccomp-profile-root flag is deprecated since Kubernetes v1.19

# add seccomp profile in pod defination
# default profile location: /var/lib/kubelet/seccomp

# pod definition 
...
spec:
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: audit.json
...      
```

# 6. Supporting Utilities

## 6.1. Curl command
```bash
curl https://secure-ingress.com:31047/service1 -kv --resolve secure-ingress.com:31047:34.105.246.174
curl https://secure-ingress.com:80/service1 -kv --resolve secure-ingress.com:80:34.105.246.174
```

## 6.2. Check SSL Certificate
```bash
# check certificate information
openssl x509 -in cert.pem -text
```

## 6.3. Create SSL Certificate
```bash
openssl help req
# generate cert and key which can be used in tls secret
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -new -nodes -subj "/CN=test.com"
```

---

# 7. References
- [Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kube-bench](https://github.com/aquasecurity/kube-bench)
- [gVisor](https://gvisor.dev/docs/user_guide/install/)

---
# 8. Appendix

## 8.1. [gVisor Installation](https://gvisor.dev/docs/user_guide/install/)
```bash
# https://gvisor.dev/docs/user_guide/install/
# gVisor / runsc
# install gVisor
curl -fsSL https://gvisor.dev/archive.key | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64,arm64] https://storage.googleapis.com/gvisor/releases release main"
sudo apt-get update && sudo apt-get install -y runsc

# create runsc config
sudo vi /etc/containerd/config.toml

# Find the disabled_plugins section and add the restart plugin.
 disabled_plugins = ["io.containerd.internal.v1.restart"]

# Find the block [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]. 
# After the existing runc block, add configuration for a runsc runtime. It should look like this when done:

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v1"
    runtime_engine = ""
    runtime_root = ""
    privileged_without_host_devices = false
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
    runtime_type = "io.containerd.runsc.v1"

# Locate the block and set   to true .
[plugins."io.containerd.runtime.v1.linux"] ...
  shim_debug = true

sudo systemctl restart containerd
sudo systemctl status containerd
```

## 8.2. Allow DNS traffic
```bash
cat <<EOF>allow-dns-traffic.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-traffic
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  # allow DNS resolution
  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
EOF
k create -f allow-dns-traffic.yaml
```
## 8.3. Deny all traffic
```bash
cat <<EOF>>default-deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress  
EOF
k -f default-deny-all.yaml create
```

## 8.4. Allow all ingress traffic
```bash
cat <<EOF>>allow-all-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
EOF
k -f allow-all-ingress.yaml create
```


