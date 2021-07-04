
# Kubernetes Installation Document

- [Kubernetes Installation Document](#kubernetes-installation-document)
  - [Document History](#document-history)
  - [Introduction](#introduction)
  - [VMs Spin Using Vagrant Config File](#vms-spin-using-vagrant-config-file)
  - [References](#references)
  
---

## Document History
```
2021-07-04 V1 "Initial k8s installation doc"
```

## Introduction
Two node kubernetes cluster using vagrant + virtualbox.


## VMs Spin Using Vagrant Config File
**Install kubernetes cluster** in local or any cloud provider virtual machine.  [`Vagrant config file`](vagrant-k8s-lab/Vagrantfile) for creating two VM.

```bash
# create vagrant pc in local environment
mkdir -p ~/vagrant-k8s-lab
cd ~/vagrant-k8s-lab
# copy vagrant config file here, adjust vagrant config file as per requirements like cpu, memory, disk and number of VMs 

#setup vagrant current working directory see only your vms as per config file
export VAGRANT_CWD=~/vagrant-k8s-lab/
vagrant status
vagrant up k8s-master
vagrant up k8s-worker1
```

Install kubernetes software in k8s-master node
```bash
# install kubernetes software in cks-master node, upload cks_install_master.sh script
vagrant ssh k8s-master
sudo ./cks_install_master.sh
```

Install kubernetes software in k8s-worker1 node
```bash
# install kubernetes software in cks-worker1 node, upload cks_install_worker.sh script
vagrant ssh k8s-worker1
sudo ./cks_install_worker.sh
```

---

## References
