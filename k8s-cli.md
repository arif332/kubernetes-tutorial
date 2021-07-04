# Kubernetes Commands

- [Kubernetes Commands](#kubernetes-commands)
  - [Document History](#document-history)
  - [Introduction](#introduction)
    - [Vim profile to setup](#vim-profile-to-setup)
    - [Environment varible to setup](#environment-varible-to-setup)
  - [K8s Imperative Command](#k8s-imperative-command)
    - [Create a busybox pod for testing](#create-a-busybox-pod-for-testing)
    - [Create a depoloyment and expose service](#create-a-depoloyment-and-expose-service)
    - [Add labels](#add-labels)
    - [Create Ingress Resource](#create-ingress-resource)
    - [Get events](#get-events)
    - [DNS record check](#dns-record-check)
    - [Kube-bench: CIS bunchmark tool](#kube-bench-cis-bunchmark-tool)
  - [Supporting Utilities](#supporting-utilities)
    - [Curl command](#curl-command)
    - [Create SSL Certificate](#create-ssl-certificate)
  - [References](#references)
  - [Appendix](#appendix)
    - [Allow DNS traffic](#allow-dns-traffic)
    - [Deny all traffic](#deny-all-traffic)
    - [Allow all ingress traffic](#allow-all-ingress-traffic)

---

## Document History
```
2021-07-04 V1 "Initial k8s imperative command"
```

## Introduction

### Vim profile to setup
```bash
cat <<EOF>~/.vimrc
set ts=2 sw=2 sts=2 et ai number
syntax on
colorscheme ron
EOF
# other options - paste, nopaste
```

### Environment varible to setup
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
## K8s Imperative Command

### Create a busybox pod for testing
```bash
# buysbox pod with curl command
k run client --image=radial/busyboxplus:curl -- /bin/sh -c "sleep 3600"
# busybox pod with curl command and log write 
k run client --image=radial/busyboxplus:curl --command -- /bin/sh -c "while true; do echo hi; sleep 10; done"

#busybox with sh/bash
k exec -it client -- sh
k exec client -- curl ip

k run -i --tty busybox --image=busybox:1.28 -- sh  # Run pod as interactive shell
k attach busybox -c busybox -i -t

# more debugging
k exec client -- nslookup client
```

### Create a depoloyment and expose service
```bash
k create deployment nginx --image=nginx -r 3

#port=service port, target-port=pod port,
k expose deployment nginx --port=80 --target-port=8080 --name nginx-svc
```

### Add labels
```bash
k label ns nptest project=test
k label pods client role=client
```

### Create Ingress Resource 
```bash
# exact match with a tls certificate, need to know svc name and port of svc
k create ingress simple --rule="foo.com/bar=svc1:8080,tls=my-cert"

# any match with a tls, need to know svc name and port of svc
k create ingress simple --rule="foo.com/*=svc1:8080,tls=my-cert"
```
### Get events
```bash
k get ev -w
```

### DNS record check
```bash
k apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
k exec -it dnsutils -- nslookup kubernetes.default
k exec client -- cat /etc/resolv.conf
k exec client -- nslookup pod-name

#dns sever check
k logs -n kube-system -l k8s-app=kube-dns
```

### Kube-bench: CIS bunchmark tool
```bash
k apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-master.yaml
k apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-node.yaml
k get pods
k logs <Control Plane Job Pod name> > kube-bench-results-control-plane.log

k get jobs
k delete job kube-bench-master
``` 

## Supporting Utilities

### Curl command
```bash
curl https://secure-ingress.com:31047/service1 -kv --resolve secure-ingress.com:31047:34.105.246.174
curl https://secure-ingress.com:80/service1 -kv --resolve secure-ingress.com:80:34.105.246.174
```

### Create SSL Certificate
```bash
openssl help req
# generate cert and key which can be used in tls secret
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -new -nodes -subj "/CN=test.com"
```


---

## References
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://github.com/aquasecurity/kube-bench

---
## Appendix

### Allow DNS traffic
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
### Deny all traffic
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

### Allow all ingress traffic
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


