# Kubespray Offline Install



admin : 10.0.1.14

node1 : 10.0.1.15

node2 : 10.0.1.16

node3 : 10.0.1.17

node4 : 10.0.1.18

node5 : 10.0.1.19



OS: RHEL7.7

master nodes :  node1, node2, node3

etcd : node1, node2, node3 

worker nodes :  node1, node2, node3, node4, node5

admin node : admin



## Prerequisites:

### DNS off (all servers)
vi /etc/ssh/sshd_config
```
...
UseDNS no
...
```

sshd restart
```
service sshd start
```



### Enable passwordless login between all servers in the cluster.

https://www.tecmint.com/ssh-passwordless-login-using-ssh-keygen-in-5-easy-steps/

1. Create Authentication SSH-Kegen Keys on node1

   ```
   ssh-keygen -t rsa
   ```

2. Create .ssh Directory on node2~5

   ```
   mkdir -p /root/.ssh
   ```

3. Upload Generated Public Keys to node2~5

   ```
   # copy id_rsa.pub from node1
   cat /root/.ssh/id_rsa.pub
   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA ... qjc
   
   # paste id_rsa.pub to node1~5
   echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA ... qjc" >> /root/.ssh/authorized_keys
   ```



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



### Disable SELinux: 

On all Servers:

```
setenforce 0

sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
```



### Set the firewall rules

On all Servers:

```
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd --permanent --add-port=179/tcp     # calico BGP
firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1
```



If possible, you can stop firewall service on all servers in the cluster:

```
systemctl stop firewalld
```

### 

### Host file update on all servers

```
echo "10.0.1.14 admin" >> /etc/hosts
```

OS Reboot

```
init 6
```



### yum repo update on all servers

불필요한 repo 정리(삭제 또는 이름 변경)

```
cd /etc/yum.repos.d/
mv rh-cloud.repo rh-cloud.repo.bk
```



custom repo 추가 - admin 서버로 설정

vi custom.repo

```
[Custum-Repo]
name=custom repo
baseurl=http://admin/repo/
enabled=1
gpgcheck=0
```

files install for rhel 7.6 
```
# copy yum_rhel76.tar to /root
cd /root
tar xf yum_rhel76.tar
cd yum_rhel76

rpm -Uvh audit-libs-2.8.5-4.el7.x86_64.rpm audit-2.8.5-4.el7.x86_64.rpm audit-libs-python-2.8.5-4.el7.x86_64.rpm
rpm -Uvh libssh2-1.8.0-3.el7.x86_64.rpm
rpm -Uvh policycoreutils-2.5-33.el7.x86_64.rpm policycoreutils-python-2.5-33.el7.x86_64.rpm
rpm -ivh python2-pyasn1-0.1.9-7.el7.noarch.rpm
```

```
yum update -y
```



### Install some prerequisites packages on all servers in the cluster

**epel-release**  ->

```
cd /root
scp root@admin:/var/www/repo/epel-release-latest-7.noarch.rpm .

rpm -ivh epel-release-latest-7.noarch.rpm
```



**Python:**

```
yum install -y python2-pip
yum install -y python36
```



**Ansible:**

$KUBESPRAY/requirements.txt  참조

```
yum install -y ansible

scp admin:/var/www/piprepo.tar .
tar xf piprepo.tar
cd piprepo

pip install netaddr-0.7.19-py2.py3-none-any.whl
pip install Jinja2-2.10.1-py2.py3-none-any.whl  MarkupSafe-1.1.1-cp27-cp27mu-manylinux1_x86_64.whl
pip install ruamel.ordereddict-0.4.14-cp27-cp27mu-manylinux1_x86_64.whl ruamel.yaml-0.15.96-cp27-cp27mu-manylinux1_x86_64.whl
```



## Kubespray

### Git clone the Kubespray repository on one of the master servers:

offline 환경에서는 git clone이 불가능하므로 미리 admin server에 저장한 파일 복사



node1

```
cd /root
scp root@admin:/var/www/kubespray_origin.tar .
tar xf kubespray_origin.tar
```



### Copy inventory/sample as inventory/mycluster

```
cd kubespray
cp -R inventory/sample/ inventory/mycluster
```



### Update the Ansible inventory file with inventory builder

```
touch inventory/mycluster/hosts.yml

declare -a IPS=(10.0.1.15 10.0.1.15 10.0.1.15 10.0.1.15 10.0.1.15)
CONFIG_FILE=inventory/mycluster/hosts.yml python contrib/inventory_builder/inventory.py ${IPS[@]}
```



### Kubespray Configuration File Modify

\#kubespray config

 vi inventory/mycluster/group_vars/all/all.yml

```
## External LB example config
## apiserver_loadbalancer_domain_name: "elb.some.domain"
# loadbalancer_apiserver:
#   address: 1.2.3.4
#   port: 1234
apiserver_loadbalancer_domain_name: 10.0.1.14
loadbalancer_apiserver:
  address: 10.0.1.14
  port: 16443

```



 vi inventory/mycluster/group_vars/all/docker.yml

```
## An obvious use case is allowing insecure-registry access to self hosted registries.
## Can be ipaddress and domain_name.
## example define 172.19.16.11 or mirror.registry.io
docker_insecure_registries:
#  - mirror.registry.io
 - 10.0.1.14:5000
```



vi inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml 

```
# kubernetes image repo define
gcr_image_repo: "admin:5000"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
docker_image_repo: "admin:5000"

# quay image repo define
quay_image_repo: "admin:5000"
```





vi roles/container-engine/docker/defaults/main.yml

```
#CentOS/RedHat docker-ce repo
#docker_rh_repo_base_url: 'https://download.docker.com/linux/centos/7/$basearch/stable'
#docker_rh_repo_gpgkey: 'https://download.docker.com/linux/centos/gpg'
docker_rh_repo_base_url: 'http://admin/docker-ce/linux/centos/7/$basearch/stable'
docker_rh_repo_gpgkey: 'http://admin/docker-ce/linux/centos/gpg'

#CentOS/RedHat Extras repo
#extras_rh_repo_base_url: "http://mirror.centos.org/centos/$releasever/extras/$basearch/"
#extras_rh_repo_gpgkey: "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7"
extras_rh_repo_base_url: "http://admin/docker-mirror/centos/$releasever/extras/$basearch/"
extras_rh_repo_gpgkey: "http://admin/docker-mirror/centos/RPM-GPG-KEY-CentOS-7"
```





\* 주요 다운로드 URL을 내부망으로 변경

vi roles/download/defaults/main.yml

```
# gcr and kubernetes image repo define
#gcr_image_repo: "gcr.io"
gcr_image_repo: "admin:5000"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
#docker_image_repo: "docker.io"
docker_image_repo: "admin:5000"

# quay image repo define
#quay_image_repo: "quay.io"
quay_image_repo: "admin:5000"

...

#kubelet_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
#kubectl_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
#kubeadm_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
#etcd_download_url: "https://github.com/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
#cni_download_url: "https://github.com/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
#calicoctl_download_url: "https://github.com/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
#crictl_download_url: "https://github.com/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"

kubelet_download_url: "http://admin/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
kubectl_download_url: "http://admin/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
kubeadm_download_url: "http://admin/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
etcd_download_url: "http://admin/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
cni_download_url: "https://admin/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
calicoctl_download_url: "http://admin/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
crictl_download_url: "http://admin/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
```



\* system hostname

vi roles/bootstrap-os/defaults/main.yml

```
## General
# Set the hostname to inventory_hostname
#override_system_hostname: true
override_system_hostname: false
```



### kubespray install

install

```
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml --flush-cache
```

reset

```
ansible-playbook -i inventory/mycluster/hosts.yml reset.yml --flush-cache 
```
