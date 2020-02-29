# Kubespray on RHEL7



OS: RHEL7.7

master nodes :  node1, node2, node3

etcd : node1, node2, node3 

worker nodes :  node1, node2, node3, node4, node5



## Prerequisites:

### Disable SELinux: 

```
setenforce 0

sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
```



### Set the firewall rules

On all “master” Servers:

```
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1
```



On all “node” servers:

```
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1
```



If possible, you can stop firewall service on all servers in the cluster:

```
systemctl stop firewalld
```



### Install some prerequisites packages on all servers in the cluster

**Ansible:**

```
yum install -y epel-release
yum install -y ansible
```



**Jinja:**

```
easy_install pip
pip2 install jinja2 --upgrade
```



**Python:**

```
yum install –y python36 
```



### Enable passwordless login between all servers in the cluster.

https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/



[Enable Root account](https://www.51sec.org/2019/08/03/how-to-enable-root-account-and-enable-username-password-access-in-gcp/)

1. Edit sshd_config file

   ```
   vi /etc/ssh/sshd_config
   ...
   PermitRootLogin yes
   ...
   ```

2. Restart ssh server

   ```
   systemctl restart sshd
   or 
   service sshd restart
   ```





### Git clone the Kubespray repository on one of the master servers:

```
yum install -y git
git clone https://github.com/kubernetes-incubator/kubespray.git
```



### Go to the ‘Kubespray’ directory and install all dependency packages

```
cd kubespray
pip install -r requirements.txt
```



Note:  While installing all requirements packages, if you get errors related to “requests” package, follow the steps below:

\- Download the latest “requests” package (.tar.gz file)

\- Untar the tar file and run command --- python setup.py install 

\- If the requests issue still doesn't resolve, go to "/usr/lib/python2.7/site-packages" and rename all requests files and folders there, and re-run the requirements.txt deployment.

```
curl https://files.pythonhosted.org/packages/f5/4f/280162d4bd4d8aad241a21aecff7a6e46891b905a4341e7ab549ebaf7915/requests-2.23.0.tar.gz -o requests-2.23.0.tar.gz

tar xf requests-2.23.0.tar.gz
cd requests-2.23.0
python setup.py install
cd ..
```





### Copy inventory/sample as inventory/mycluster

```
cp -R inventory/sample/ inventory/mycluster
```



### Update the Ansible inventory file with inventory builder

```
pip3.6 install ruamel.yaml

declare -a IPS=(10.128.15.199 10.128.15.200 10.128.15.201 10.128.15.202 10.128.15.203)
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```



Note: While updating ansible inventory, if you get errors related to “ruamel.yaml”, follow the step below:

Error message:

```
Traceback (most recent call last):
 File "contrib/inventory_builder/inventory.py", line 40, in <module>
  from ruamel.yaml import YAML
ModuleNotFoundError: No module named 'ruamel'
```



```
pip3.6 install ruamel.yaml
```

Link: https://github.com/kubernetes-sigs/kubespray/issues/4318



### Review and change parameters under ``inventory/mycluster/group_vars``



* Changing the network

vi inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml

```
# Choose network plugin (cilium, calico, contiv, weave or flannel. Use cni for generic cni plugin)
# Can also be set to 'cloud', which lets the cloud provider setup appropriate routing

kube_network_plugin: weave
```



* Enabling metrics to fetch the cluster resource utilization data

ex) kubectl top nodes & kubectl top pods



vi inventory/mycluster/group_vars/all/all.yml

```
## The read-only port for the Kubelet to serve on with no authentication/authorization. Uncomment to enable.

kube_read_only_port: 10255
```



### Deploy Kubespray with Ansible Playbook

```
yum install -y ipvsadm
```



```
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml 
```







https://github.com/kubernetes-sigs/kubespray

https://waspro.tistory.com/558

https://dzone.com/articles/kubespray-10-simple-steps-for-installing-a-product



