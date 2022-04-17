
**Table of Contents**
- [Introduction](#introduction)
- [Create a K3d+K3s Cluster](#create-a-k3dk3s-cluster)
- [Determine IP address from running K3d+K3s Cluster Config](#determine-ip-address-from-running-k3dk3s-cluster-config)
- [Install metallb](#install-metallb)
- [Install Nginx Ingress Controller](#install-nginx-ingress-controller)
- [Docker Mac Net to Connect Docker Application Using IP Address](#docker-mac-net-to-connect-docker-application-using-ip-address)
- [References](#references)
- [Appendix](#appendix)


# Introduction

This article focuses on installing a k3s cluster using k3d and planning to use nginx ingress and metallb instead of default traefik and servicelb.



# Create a K3d+K3s Cluster

Use below argument to disable default traefik and servicelb :
- for traefik `--no-deploy traefik`
- for servicelb `--disable servicelb`

Use below command to create a cluster without default traefik and servicelb.
```bash
# create k3d cluster without traefik
k3d cluster create local-k8s --servers 1 --agents 1 --k3s-arg --no-deploy=traefik --wait

# create k3d cluster without traefik and servicelb
# k3d cluster create k3s-demo-cluster --api-port 6550 --agents 1 --k3s-arg "--disable=traefik@server:0" --k3s-arg "--disable=servicelb@server:0" --no-lb --wait
k3d cluster create k3s-demo-cluster --agents 1 --k3s-arg "--disable=traefik@server:0" --k3s-arg "--disable=servicelb@server:0" --no-lb --wait

# set kubeconfig to access the k8s context
export KUBECONFIG=$(k3d kubeconfig write local-k8s)

# validate the cluster master and worker nodes
kubectl get nodes

# we don't see any pods related to traefik & servicelb
kubectl get pods -A
```

# Determine IP address from running K3d+K3s Cluster Config
We need to find the IP address series that uses by docker for the created k3d+k3s Kubernetes cluster. 

```bash
# install jq package as per your host platform os
# for ubuntu: sudo apt install jq -y
# for macos: brew install jq
# docker network inspect k3s-demo-cluster | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"'

# determine loadbalancer ingress range
cidr_block=$(docker network inspect k3d-k3s-demo-cluster | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
cidr_base_addr=${cidr_block%???}
ingress_first_addr=$(echo $cidr_base_addr | awk -F'.' '{print $1,$2,255,0}' OFS='.')
ingress_last_addr=$(echo $cidr_base_addr | awk -F'.' '{print $1,$2,255,255}' OFS='.')
ingress_range=$ingress_first_addr-$ingress_last_addr
```


# Install metallb
```bash
# deploy metallb 
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
```

Now create configuration for the load balancer IP address in metallb-system namespace.
```yaml
# configure metallb ingress address range
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $ingress_range
EOF
```


# Install Nginx Ingress Controller
Install nginx ingress controller using below commands.
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.2/deploy/static/provider/cloud/deploy.yaml
kubectl -n ingress-nginx get svc ingress-nginx-controller
```
           
Now create an nginx web server application, service and ingress configuration to test nginx ingress controller functionalities.

```bash
# create a deployment (i.e. nginx)
kubectl create deployment nginx --image=nginx

# expose the deployments using a LoadBalancer
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# check external ip address 
k get svc nginx 

# obtain the ingress external ip
# external_ip=$(k get svc nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# test the loadbalancer external ip
# curl $external_ip

# now create ingress configuration
kubectl create ingress testingress --rule="foo.test/=nginx:80" --default-backend=nginx:80 

# now edit ingress configuration add below annotation so that ingress configuration can get an IP address for the domain name foo.test
kubectl edit ingress testingress 
#   annotations:
#     kubernetes.io/ingress.class: nginx

# now check ip address
kubectl get ingress testingress         
```


Once the IP address can be seen for the nginx ingress controller, we can publish the same ip address and domain name in the external dns server so that the external node/host can send traffic to our nginx ingress controller that serves by ngix application.

Added below information in dnsmasp.conf(/opt/homebrew/etc/dnsmasq.conf) on the macos. Hosts file (/etc/hosts) can be used to resolve ip address instead of dnsmasq/dns server. 

```bash
# use ip address that seen using below command
kubectl get ingress testingress   
# /opt/homebrew/etc/dnsmasq.conf
address=/foo.test/172.23.255.1

# restart dns service 
sudo brew services restart dnsmasq
```

If the host os is Linux, follow the below command to test the service. If host os is macOS, follow the next section to install software to help communicate between host os and docker application using the allocated IP address by docker. From browser we can try `http://foo.test`.

```bash
curl http://foo.test:80 -kv --resolve foo.test:80:172.23.255.1
```



# Docker Mac Net to Connect Docker Application Using IP Address
```bash
# Install via Homebrew
$ brew install chipmk/tap/docker-mac-net-connect

# Run the service and register it to launch at boot
$ sudo brew services start chipmk/tap/docker-mac-net-connect


# To restart chipmk/tap/docker-mac-net-connect after an upgrade:
brew services restart chipmk/tap/docker-mac-net-connect
# Or, if you don't want/need a background service you can just run:
/opt/homebrew/opt/docker-mac-net-connect/bin/docker-mac-net-connect
```



# References
- https://medium.com/linux-shots/spin-up-a-lightweight-kubernetes-cluster-on-linux-with-k3s-metallb-and-nginx-ingress-167d98f3583d
- https://dzone.com/articles/how-to-create-a-kubernetes-cluster-and-load-balanc
- https://golangexample.com/connect-directly-to-docker-for-mac-containers-via-ip-address/
- https://blog.kubernauts.io/k3s-with-k3d-and-metallb-on-mac-923a3255c36e
- https://en.wikipedia.org/wiki/WireGuard
- https://github.com/AlmirKadric-Published/docker-tuntap-osx
- https://blog.kubernauts.io/k3s-with-k3d-and-metallb-on-mac-923a3255c36e
- https://mjpitz.com/blog/2020/10/21/local-ingress-domains-kind/
- https://www.suse.com/support/kb/doc/?id=000020082


# Appendix

Ingress yaml file for foo.test. Annotations is important setting, ingress is not able to populate ip address without it.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  creationTimestamp: "2022-04-12T13:14:34Z"
  generation: 1
  name: testingress
  namespace: default
  resourceVersion: "12304"
  uid: f25514f7-5bca-4fbe-a5f4-ad8466d20702
spec:
  defaultBackend:
    service:
      name: nginx
      port:
        number: 80
  rules:
  - host: foo.test
    http:
      paths:
      - backend:
          service:
            name: nginx
            port:
              number: 80
        path: /
        pathType: Exact
status:
  loadBalancer:
    ingress:
    - ip: 172.23.255.1
```

```bash
% k get ingress
NAME          CLASS    HOSTS         ADDRESS   PORTS   AGE
testingress   <none>   foo.test             80      14m
%

% k get ingress testingress         
NAME          CLASS    HOSTS         ADDRESS        PORTS   AGE
testingress   <none>   foo.test   172.23.255.1   80      26m
% 

$ curl http://foo.bar.com:80 -kv --resolve foo.test:80:172.23.255.1
```