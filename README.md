# Inception of Things

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

