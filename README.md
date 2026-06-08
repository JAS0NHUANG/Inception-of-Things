# Inception of Things

## Preperation

This project is done inside a ubuntu VM with 6000MB RAM, 6 cpus and 50G hard drive.
(Still haveing bugs launching some script at school under nested VM)

- tools:
installation script:
curl, git, vim, openssh-server, gnupg

vagrant

virtualbox

Docker

K3d

kubectl

ArgoCD CLI

HELM

### Need to deactivate KVM to make things work
`lsmod | grep kvm` to see all kvm modules


All the tools and needed config can be done by launching the installation script.

## p1 - Vagrant/K3s

[p1 - notes](/p1/README.md)


## Vagrant
### install
[Vagrant - install - Linux](https://developer.hashicorp.com/vagrant/install#Linux)  
Need to change `$(lsb_release -cs)` part to `lunar` on Ubuntu latter then 23.04(Lunar)   

### Vagrantfile 
- Global setting:
```
config.vm
```
- For specific VM:
```
config.vm.define "server_name" do |server_alias|
  server_alias.vm
end
```

### Vagrant Commands
`vagrant up` - spin up VMs' according to the Vagrantfile  
`vagrant status` - check vagrant and VMs' status  
`vagrant destroy` - DESTROY VMs  

## K3s

## K3d

## Argo CD
[Argo CD](https://argo-cd.readthedocs.io/en/stable/)

