

redhat 7.7

# Provisioning Compute Resources

## Networking

### Virtual Private Cloud Network

Create the `kubernetes-vpc` custom VPC network:

```
gcloud compute networks create kubernetes-vpc --subnet-mode custom
```

Create the `kubernetes` subnet in the `kubernetes-vpc VPC` network:

```
gcloud compute networks subnets create kubernetes \
  --network kubernetes-vpc --region us-central1 \
  --range 10.233.0.0/18
```



### Firewall Rules

Create a firewall rule that allows internal communication across all protocols:

```
gcloud compute firewall-rules create kubernetes-allow-internal \
  --allow tcp,udp,icmp \
  --network kubernetes-vpc \
  --source-ranges 10.233.0.0/18
```

Create a firewall rule that allows external SSH, ICMP, and HTTPS:

```
gcloud compute firewall-rules create kubernetes-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network kubernetes-vpc \
  --source-ranges 0.0.0.0/0
```

List the firewall rules in the `kubernetes-vpc` VPC network:

```
gcloud compute firewall-rules list --filter="network:kubernetes-vpc"
```



## Compute Instances

### Kubernetes Controllers

```
for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 10GB \
    --can-ip-forward \
    --image=rhel-7-v20200205 \
    --image-project rhel-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.233.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes,controller \
    --preemptible \
    --zone=us-central1-a 
    
done
```



### Kubernetes Workers

```
for i in 0 1 ; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 10GB \
    --can-ip-forward \
    --image=rhel-7-v20200205 \
    --image-project rhel-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.233.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes,worker \
    --preemptible \
    --zone=us-central1-a 
done
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



## Prerequisites:

### Disable SELinux: 

```
setenforce 0
setenforce Disabled

sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
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

Or all

```
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
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



tar files

```
#curl -OL http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/libselinux-python-2.5-14.1.el7.x86_64.rpm

curl -OL http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-netaddr-0.7.5-9.el7.noarch.rpm
```









# Ansible 설치

### 1.Install ansible with tar file

```
curl -OL https://github.com/ieyei/kubernetes/releases/download/1.0.0/ansible-install.tar.gz

```





### 2.Install ansible with download

### ansible download

https://releases.ansible.com/ansible/rpm/release/

```
mkdir ansible-install
cd ansible-install

curl -OL https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.9.5-1.el7.ans.noarch.rpm
```

### 

```
# yum localinstall ansible-2.9.5-1.el7.ans.noarch.rpm
...

======================================================
 Package                     Arch     Version         
======================================================
Installing:
 ansible                     noarch   2.9.5-1.el7.ans 
Installing for dependencies:
 PyYAML                      x86_64   3.10-11.el7     
 libyaml                     x86_64   0.1.4-11.el7_0  
 python-babel                noarch   0.9.6-8.el7     
 python-cffi                 x86_64   1.6.0-5.el7     
 python-enum34               noarch   1.0.4-1.el7     
 python-idna                 noarch   2.4-1.el7       
 python-jinja2               noarch   2.7.2-4.el7     
 python-markupsafe           x86_64   0.11-10.el7     
 python-paramiko             noarch   2.1.1-9.el7     
 python-ply                  noarch   3.4-11.el7      
 python-pycparser            noarch   2.14-1.el7      
 python2-cryptography        x86_64   1.7.2-2.el7     
 sshpass                     x86_64   1.06-2.el7      

Transaction Summary
======================================================
```



**dependencies**

* [PyYAML](https://www.rpmfind.net/linux/rpm2html/search.php?query=pyyaml)
  * [libyaml](https://www.rpmfind.net/linux/rpm2html/search.php?query=libyaml&submit=Search+...&system=&arch=)
* [python-jinja2](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-jinja2&submit=Search+...&system=&arch=)
  * [python-babel](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-babel&submit=Search+...&system=&arch=)
  * [python-markupsafe](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-markupsafe&submit=Search+...&system=&arch=)
* [python2-cryptography](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-crypto)
  * [python-cffi](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-cffi&submit=Search+...&system=&arch=)
    * [python-pycparser](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-pycparser&submit=Search+...&system=&arch=)
    * [python-ply](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-ply&submit=Search+...&system=&arch=)
  * [python-enum34](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-enum34&submit=Search+...&system=&arch=)
  * [python-idna](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-idna&submit=Search+...&system=&arch=)
* [python-paramiko](https://www.rpmfind.net/linux/rpm2html/search.php?query=python-paramiko&submit=Search+...&system=&arch=)
* [sshpass](https://www.rpmfind.net/linux/rpm2html/search.php?query=sshpass&submit=Search+...&system=&arch=)





```


curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/PyYAML-3.10-11.el7.x86_64.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/libyaml-0.1.4-11.el7_0.x86_64.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-jinja2-2.7.2-4.el7.noarch.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-babel-0.9.6-8.el7.noarch.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-markupsafe-0.11-10.el7.x86_64.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-paramiko-2.1.1-9.el7.noarch.rpm
curl -OL https://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python2-cryptography-1.7.2-2.el7.x86_64.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-cffi-1.6.0-5.el7.x86_64.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-enum34-1.0.4-1.el7.noarch.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-idna-2.4-1.el7.noarch.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-pycparser-2.14-1.el7.noarch.rpm
curl -OL https://www.rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-ply-3.4-11.el7.noarch.rpm
curl -OL https://www.rpmfind.net/linux/epel/7/x86_64/Packages/s/sshpass-1.06-1.el7.x86_64.rpm

```



### ansible install

```
rpm -ivh ./ansible-install/*.rpm --force
```



# Docker registry

## Private registry에 이미지 등록

Registry : nxgregistry.azurecr.io



### docker tag (local)

```
docker tag gcr.io/google-containers/kube-controller-manager:v1.16.6				  nxgregistry.azurecr.io/google-containers/kube-controller-manager:v1.16.6
docker tag gcr.io/google-containers/kube-apiserver:v1.16.6                        nxgregistry.azurecr.io/google-containers/kube-apiserver:v1.16.6
docker tag gcr.io/google-containers/kube-proxy:v1.16.6                            nxgregistry.azurecr.io/google-containers/kube-proxy:v1.16.6
docker tag gcr.io/google-containers/kube-scheduler:v1.16.6                        nxgregistry.azurecr.io/google-containers/kube-scheduler:v1.16.6
docker tag calico/node:v3.11.1                                                    nxgregistry.azurecr.io/calico/node:v3.11.1
docker tag calico/cni:v3.11.1                                                     nxgregistry.azurecr.io/calico/cni:v3.11.1
docker tag calico/kube-controllers:v3.11.1                                        nxgregistry.azurecr.io/calico/kube-controllers:v3.11.1
docker tag gcr.io/google-containers/k8s-dns-node-cache:1.15.8                     nxgregistry.azurecr.io/google-containers/k8s-dns-node-cache:1.15.8
docker tag coredns/coredns:1.6.0                                                  nxgregistry.azurecr.io/coredns/coredns:1.6.0
docker tag weaveworks/weave-kube:2.5.2                                            nxgregistry.azurecr.io/weaveworks/weave-kube:2.5.2
docker tag weaveworks/weave-npc:2.5.2                                             nxgregistry.azurecr.io/weaveworks/weave-npc:2.5.2
docker tag gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0   nxgregistry.azurecr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
docker tag gcr.io/google_containers/kubernetes-dashboard-amd64:v1.10.1            nxgregistry.azurecr.io/google_containers/kubernetes-dashboard-amd64:v1.10.1
docker tag quay.io/coreos/etcd:v3.3.10                                            nxgregistry.azurecr.io/coreos/etcd:v3.3.10
docker tag gcr.io/google-containers/pause:3.1                                     nxgregistry.azurecr.io/google-containers/pause:3.1
docker tag gcr.io/google_containers/pause-amd64:3.1                               nxgregistry.azurecr.io/google_containers/pause-amd64:3.1
docker tag lachlanevenson/k8s-helm:v3.1.0										  nxgregistry.azurecr.io/lachlanevenson/k8s-helm:v3.1.0
docker tag gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0  nxgregistry.azurecr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
```



### docker login

모든 노드

```
docker login nxgregistry.azurecr.io
```



### docker push

```
docker push nxgregistry.azurecr.io/google-containers/kube-controller-manager:v1.16.6
docker push nxgregistry.azurecr.io/google-containers/kube-apiserver:v1.16.6
docker push nxgregistry.azurecr.io/google-containers/kube-proxy:v1.16.6
docker push nxgregistry.azurecr.io/google-containers/kube-scheduler:v1.16.6
docker push nxgregistry.azurecr.io/calico/node:v3.11.1
docker push nxgregistry.azurecr.io/calico/cni:v3.11.1
docker push nxgregistry.azurecr.io/calico/kube-controllers:v3.11.1
docker push nxgregistry.azurecr.io/google-containers/k8s-dns-node-cache:1.15.8
docker push nxgregistry.azurecr.io/coredns/coredns:1.6.0
docker push nxgregistry.azurecr.io/weaveworks/weave-kube:2.5.2
docker push nxgregistry.azurecr.io/weaveworks/weave-npc:2.5.2
docker push nxgregistry.azurecr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
docker push nxgregistry.azurecr.io/google_containers/kubernetes-dashboard-amd64:v1.10.1
docker push nxgregistry.azurecr.io/coreos/etcd:v3.3.10
docker push nxgregistry.azurecr.io/google-containers/pause:3.1
docker push nxgregistry.azurecr.io/google_containers/pause-amd64:3.1	
docker push nxgregistry.azurecr.io/lachlanevenson/k8s-helm:v3.1.0
```







# Kuberspray Install

$KUBESPRAY/roles/download/defaults/main.yml 수정

```
vi roles/download/defaults/main.yml

...
# gcr and kubernetes image repo define
gcr_image_repo: "gcr.io"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
docker_image_repo: "docker.io"

# quay image repo define
quay_image_repo: "quay.io"
...

# 아래와 같이 수정
...
# gcr and kubernetes image repo define
gcr_image_repo: "nxgregistry.azurecr.io"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
docker_image_repo: "nxgregistry.azurecr.io"

# quay image repo define
quay_image_repo: "nxgregistry.azurecr.io"
...
```



Docker registry가 http를 사용할 경우 아래 부분 수정

$KUBESPRAY_HOME/inventory/sample/group_vars/all/docker.yml 수정

```
...
# docker_insecure_registries:
#   - mirror.registry.io
#   - 172.19.16.11
...

==> 수정

...
docker_insecure_registries:
  - [registry url]
...
```



Download binary files

```
# tree /usr/local/bin
/usr/local/bin
├── etcd
├── etcdctl
├── etcd-scripts
│   └── make-ssl-etcd.sh
├── kubeadm
├── kubectl
├── kubelet
└── kubernetes-scripts
```



설치 파일 복사

```
mkdir /tmp/releases
```

대상 파일

* kubelet
* kubectl
* kubeadm
* etcd-v3.3.10-linux-amd64.tar.gz
* cni-plugins-linux-amd64-v0.8.3.tgz
* calicoctl-linux-amd64

```
mv kube* /usr/local/bin
tar zxf etcd-v3.3.10-linux-amd64.tar.gz --strip 1 -C /usr/local/bin 
tar zxf cni-plugins-linux-amd64-v0.8.3.tgz -C /usr/local/bin
chmod +x /usr/local/bin/*
chown -R root:root /usr/local/bin/
```





$KUBESPRAY/inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml

(아래 내용 추가)

```
# private install
kube_internet_install_enabled: false

kube_proxy_mode: iptables  # ipvs => iptables 수정
```





$KUBESPRAY/roles/download/defaults/main.yml 내용

```
# etcd, cni, kubeadm, kubectl, kubelet
enabled: "{{ kube_internet_install_enabled|default(true) }}" # 수정
```











```
image_arch: "{{host_architecture | default('amd64')}}"

kube_version: v1.16.6
kubeadm_version: "{{ kube_version }}"
etcd_version: v3.3.10
cni_version: "v0.8.3"
calico_ctl_version: "v3.11.1"

curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubelet -o kubelet-v1.16.6-amd64
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubectl -o kubectl-v1.16.6-amd64
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubeadm -o kubeadm-v1.16.6-amd64
curl -OL https://github.com/coreos/etcd/releases/download/v3.3.10/etcd-v3.3.10-linux-amd64.tar.gz
curl -OL https://github.com/containernetworking/plugins/releases/download/v0.8.3/cni-plugins-linux-amd64-v0.8.3.tgz
curl -OL https://github.com/projectcalico/calicoctl/releases/download/v3.11.1/calicoctl-linux-amd64
```







### Copy inventory/sample as inventory/mycluster

```
cp -R inventory/sample/ inventory/mycluster

```



### Update the Ansible inventory file 

$KUBESPRAY/inventory/mycluster/hosts.yml

```
all:
  hosts:
    controller-0:
      ansible_host: 10.233.0.10
      ip: 10.233.0.10
      access_ip: 10.233.0.10
    controller-1:
      ansible_host: 10.233.0.11
      ip: 10.233.0.11
      access_ip: 10.233.0.11
    controller-2:
      ansible_host: 10.233.0.12
      ip: 10.233.0.12
      access_ip: 10.233.0.12
    worker-0:
      ansible_host: 10.233.0.20
      ip: 10.233.0.20
      access_ip: 10.233.0.20
    worker-1:
      ansible_host: 10.233.0.21
      ip: 10.233.0.21
      access_ip: 10.233.0.21
  children:
    kube-master:
      hosts:
        controller-0:
        controller-1:
        controller-2:
    kube-node:
      hosts:
        controller-0:
        controller-1:
        controller-2:
        worker-0:
        worker-1:
    etcd:
      hosts:
        controller-0:
        controller-1:
        controller-2:
    k8s-cluster:
      children:
        kube-master:
        kube-node:
    calico-rr:
      hosts: {}
```





### External LB

$KUBESPRAY/inventory/mycluster/group_vars/all/all.yml

```
## External LB example config
## apiserver_loadbalancer_domain_name: "elb.some.domain"
# loadbalancer_apiserver:
#   address: 1.2.3.4
#   port: 1234

apiserver_loadbalancer_domain_name: 10.128.15.213
loadbalancer_apiserver:
  address: 10.128.15.213
  port: 16443
```



### Deploy Kubespray with Ansible Playbook

```
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml --flush-cache 2>&1 | tee ansible.log 
```





### Reset Kuberspray

```
ansible-playbook --flush-cache -i inventory/mycluster/hosts.yml reset.yml
```











https://waspro.tistory.com/557

https://github.com/kubernetes-sigs/kubespray/issues/4606