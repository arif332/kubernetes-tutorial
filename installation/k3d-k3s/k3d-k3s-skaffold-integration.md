
**Table of Contents:**
- [1. Local Development Pipeline Using Skaffold on Kubernetes](#1-local-development-pipeline-using-skaffold-on-kubernetes)
- [2. Installation](#2-installation)
- [3. Create a Local Container Registry using K3d](#3-create-a-local-container-registry-using-k3d)
- [4. Create a Kubernetes Cluster using K3d](#4-create-a-kubernetes-cluster-using-k3d)
- [5. Deploy Application Pipeline using Skaffold](#5-deploy-application-pipeline-using-skaffold)
- [6. References](#6-references)


# 1. Local Development Pipeline Using Skaffold on Kubernetes 

I have used Skaffold to automate a development pipeline for the Kubernetes-based application development. The development pipeline will automate repeated tasks and provide enhanced, hassle-free, faster development experiences.

List of tools:
- Skaffold: Pipeline automation software
- K3s: Lightweight Kubernetes software
- K3d: Deployed Kubernetes cluster on top of  Docker Desktop
- Docker Desktop: Host development and testing environment on top of MacOs 


# 2. Installation 

Install K3d using homebrew:
```bash
brew install k3d
```

Install Skaffold using homebrew:
```bash
brew install skaffold
```

Follow [docker website](https://docs.docker.com/desktop/mac/install/) for the Docker Desktop installation procedure.

# 3. Create a Local Container Registry using K3d

First create local container registry using K3d. The process will map a local port arbitrary (for my case 54838) to container port 5000. In the subsequent configuration we will use `k3d-registry:5000`.  
```bash
# k3d prefix will be added with name "registry"
k3d registry create registry
```

```bash
% docker ps | grep k3d-registry
3318342041e4   registry:2                 "/entrypoint.sh /etc…"   3 hours ago   Up 3 hours    0.0.0.0:54838->5000/tcp           k3d-registry
%
```

# 4. Create a Kubernetes Cluster using K3d

Now create a kubernetes cluster using K3d and use above container registry.

```bash
k3d cluster create --registry-use  k3d-registry:5000
```



# 5. Deploy Application Pipeline using Skaffold


Clone example source from Skaffold registry and move to example code folder. The repo contains basic go example code. 
```bash
git clone --depth 1 https://github.com/GoogleContainerTools/skaffold
cd skaffold/examples/getting-started
```

```bash
# tree
.
├── Dockerfile
├── k8s-pod.yaml
├── main.go
├── README.md
└── skaffold.yaml
```

Now add image registry information (`k3d-registry:5000`) before the image name. Content of k8s-pod.yaml file as follow:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: getting-started
spec:
  containers:
  - name: getting-started
    image: k3d-registry:5000/skaffold-example
```    

Now add image registry information (`k3d-registry:5000`) before the image name. skaffold.yaml file can be generated using `skaffold --init`. A sample content of skaffold.yaml file as follow:
```yaml
apiVersion: skaffold/v2beta28
kind: Config
metadata:
  name: getting-started
build:
  artifacts:
  - image: k3d-registry:5000/skaffold-example
    docker:
      dockerfile: Dockerfile
deploy:
  kubectl:
    manifests:
    - k8s-pod.yaml
```

Now start continuous deployment flow using skaffold. 
```bash
skaffold dev
```


Observe that skaffold cannot pull images from the registry and exit from the application deployment process.
```bash
$ skaffold dev
....
....
Waiting for deployments to stabilize...
 - pods: creating container getting-started
    - pod/getting-started: creating container getting-started
 - pods: container getting-started is waiting to start: localhost:54838/k3d-registry_5000_skaffold-example:8f4e453-dirty@sha256:fff5b4a514471d41cb038ac8e5ed00e9182b0bfc10f0b6e91afc8fbe7db4cd45 can't be pulled
    - pod/getting-started: container getting-started is waiting to start: localhost:54838/k3d-registry_5000_skaffold-example:8f4e453-dirty@sha256:fff5b4a514471d41cb038ac8e5ed00e9182b0bfc10f0b6e91afc8fbe7db4cd45 can't be pulled
 - pods failed. Error: container getting-started is waiting to start: localhost:54838/k3d-registry_5000_skaffold-example:8f4e453-dirty@sha256:fff5b4a514471d41cb038ac8e5ed00e9182b0bfc10f0b6e91afc8fbe7db4cd45 can't be pulled.
Cleaning up...
 - pod "getting-started" deleted
1/1 deployment(s) failed
...
```

Setup local registry as a default-repo. However, this variable setup does not resolve the above issue.
```bash
$ skaffold config set default-repo  k3d-registry:5000

$ skaffold config list                               
skaffold config: 
kube-context: k3d-k3s-default
default-repo: k3d-registry:5000
```


Finally, able to deploy the application on the Kubernetes platform once setup `default-repo` as an inline parameter.

```bash
skaffold dev --default-repo=k3d-registry:5000
 ```




# 6. References
- https://skaffold.dev/docs/quickstart/
- https://k3d.io/v5.2.0/usage/registries/
- https://k3s.io
- https://docs.docker.com/desktop/mac/install/
