# External LB Configuration in Kubernetes

- [External LB Configuration in Kubernetes](#external-lb-configuration-in-kubernetes)
  - [Document History](#document-history)
  - [Introduction](#introduction)
  - [LoadBalancing without cloud provider](#loadbalancing-without-cloud-provider)
    - [MetalLB](#metallb)
  - [Ingress controller](#ingress-controller)
  - [References](#references)

---

## Document History
```
2021-07-04 V1 "Initial draft for MetalLB"
```

## Introduction


## LoadBalancing without cloud provider

### [MetalLB](https://metallb.universe.tf/configuration/)

MetalLB can be onfigured as per [the manifests in the official website](https://metallb.universe.tf/installation/#installation-by-manifest).
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml
```

A secret already configured as part of manifests which can be checked.
```bash
k get secrets memberlist -n metallb-system
k describe secrets memberlist -n metallb-system
```

If secret is not configured then can be create a secret to secure MetalLB components communication.
```bash
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)" -o yaml --dry-run=client > metallb-secret.yaml
kubectl create -f metallb-secret.yaml
```

After installation we can be the pods as like below example -
```bash
vagrant@cks-master:~$ k get pods -n metallb-system
NAME                          READY   STATUS    RESTARTS   AGE
controller-6b78bff7d9-ns85m   1/1     Running   0          2m35s
speaker-mjpxt                 1/1     Running   0          2m35s
speaker-xvgmt                 1/1     Running   0          2m35s
vagrant@cks-master:~$
```

It povides two configuration mode -

- ARP: work any layer 2 network, simple to configure
  - Create a ip pool with help of ConfigMap. A sample [configmap](metallb/metallb-config.yml) can be check here.
- BGP


We are now ready to test our load balancers. To do so let’s move directly to our next topic.

## Ingress controller


<br>

---
## References
- https://particule.io/en/blog/k8s-no-cloud/
- https://metallb.universe.tf/
- https://kubernetes.github.io/ingress-nginx/deploy/baremetal/
