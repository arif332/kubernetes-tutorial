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
    - [Kube-bench: CIS bunchmark tool](#kube-bench-cis-bunchmark-tool)
  - [Supporting Utilities](#supporting-utilities)
    - [Curl command](#curl-command)
    - [Create SSL Certificate](#create-ssl-certificate)
  - [References](#references)

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
kubectl run client --image=radial/busyboxplus:curl -- /bin/sh -c "sleep 3600"
# busybox pod with curl command and log write 
k run client --image=radial/busyboxplus:curl --command -- /bin/sh -c "while true; do echo hi; sleep 10; done"

#busybox with sh/bash
k exec -it client -- sh
k exec client -- curl ip

kubectl run -i --tty busybox --image=busybox -- sh  # Run pod as interactive shell
kubectl attach busybox -c busybox -i -t
```

### Create a depoloyment and expose service
```bash
kubectl create deployment nginx --image=nginx -r 3

#port=service port, target-port=pod port,
kubectl expose deployment nginx --port=80 --target-port=8080 --name nginx-svc
```

### Add labels
```bash
k label namespaces nptest project=test
k label pods client role=client
```

### Create Ingress Resource 
```bash
# exact match with a tls certificate, need to know svc name and port of svc
kubectl create ingress simple --rule="foo.com/bar=svc1:8080,tls=my-cert"

# any match with a tls, need to know svc name and port of svc
kubectl create ingress simple --rule="foo.com/*=svc1:8080,tls=my-cert"
```

### Kube-bench: CIS bunchmark tool
```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-master.yaml
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-node.yaml
kubectl get pods
kubectl logs <Control Plane Job Pod name> > kube-bench-results-control-plane.log

kebectl get jobs
kubectl delete job kube-bench-master
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