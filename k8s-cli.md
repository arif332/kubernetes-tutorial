**TOC: Kubernetes Commands**

- [1. Introduction](#1-introduction)
- [2. Document History](#2-document-history)
- [3. Environment Setup](#3-environment-setup)
  - [3.1. Vim profile setup](#31-vim-profile-setup)
  - [3.2. Environment variable setup](#32-environment-variable-setup)
- [4. K8s Imperative Command](#4-k8s-imperative-command)
  - [4.1. Create a busybox pod for testing](#41-create-a-busybox-pod-for-testing)
  - [4.2. Create a deployment and expose service](#42-create-a-deployment-and-expose-service)
  - [4.3. Activity on deployment](#43-activity-on-deployment)
  - [4.4. Add labels](#44-add-labels)
  - [4.5. Create Ingress Resource](#45-create-ingress-resource)
  - [4.6. Get events](#46-get-events)
  - [4.7. DNS record check](#47-dns-record-check)
  - [4.8. Kube-bench: CIS bunchmark tool](#48-kube-bench-cis-bunchmark-tool)
- [5. Supporting Utilities](#5-supporting-utilities)
  - [5.1. Curl command](#51-curl-command)
  - [5.2. Check SSL Certificate](#52-check-ssl-certificate)
  - [5.3. Create SSL Certificate](#53-create-ssl-certificate)
- [6. References](#6-references)
- [7. Appendix](#7-appendix)
  - [7.1. Allow DNS traffic](#71-allow-dns-traffic)
  - [7.2. Deny all traffic](#72-deny-all-traffic)
  - [7.3. Allow all ingress traffic](#73-allow-all-ingress-traffic)

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
set ts=2 sw=2 sts=2 et ai number
syntax on
colorscheme ron
EOF
# other options - paste, nopaste
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

## 4.8. Kube-bench: CIS bunchmark tool
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

# 5. Supporting Utilities

## 5.1. Curl command
```bash
curl https://secure-ingress.com:31047/service1 -kv --resolve secure-ingress.com:31047:34.105.246.174
curl https://secure-ingress.com:80/service1 -kv --resolve secure-ingress.com:80:34.105.246.174
```

## 5.2. Check SSL Certificate
```bash
# check certificate information
openssl x509 -in cert.pem -text
```

## 5.3. Create SSL Certificate
```bash
openssl help req
# generate cert and key which can be used in tls secret
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -new -nodes -subj "/CN=test.com"
```

---

# 6. References
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://github.com/aquasecurity/kube-bench

---
# 7. Appendix

## 7.1. Allow DNS traffic
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
## 7.2. Deny all traffic
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

## 7.3. Allow all ingress traffic
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


