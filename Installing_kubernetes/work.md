

## Prerequisites
### Disable SELinux: 

```
sudo setenforce 0

sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux

os start
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
firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1
```




If possible, you can stop firewall service on all servers in the cluster:

```
systemctl stop firewalld
```


### ansible install
curl -OL https://github.com/ieyei/kubernetes/releases/download/1.0.0/ansible-install.tar.gz
tar xzf ansible-install.tar.gz
sudo rpm -ivh ansible-install/*.rpm


curl -OL https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.7.16-1.el7.ans.noarch.rpm
sudo rpm -ivh ansible-2.7.16-1.el7.ans.noarch.rpm

### pip install
https://pypi.org/project/pip/#files
curl -OL https://files.pythonhosted.org/packages/8e/76/66066b7bc71817238924c7e4b448abdb17eb0c92d645769c223f9ace478f/pip-20.0.2.tar.gz

tar zxf pip-20.0.2.tar.gz
cd pip-20.0.2
sudo python setup.py install

### Jinja2 install

curl -OL https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz
pip install MarkupSafe-1.1.1.tar.gz

https://pypi.org/project/Jinja2/#description
curl -OL https://files.pythonhosted.org/packages/d8/03/e491f423379ea14bb3a02a5238507f7d446de639b623187bccc111fbecdf/Jinja2-2.11.1.tar.gz
pip install Jinja2-2.11.1.tar.gz 

### files
ansible==2.7.16
jinja2==2.10.1
netaddr==0.7.19
pbr==5.2.0
hvac==0.8.2
jmespath==0.9.4
ruamel.yaml==0.15.96



curl -OL http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/python-netaddr-0.7.5-9.el7.noarch.rpm
sudo rpm -ivh python-netaddr-0.7.5-9.el7.noarch.rpm

curl -OL https://files.pythonhosted.org/packages/98/8a/defa5215d2dcf98cc80f4783e951a8356e38f352f7a169ae11670dcb1f25/pbr-5.4.4.tar.gz
pip install pbr-5.4.4.tar.gz

curl -OL https://files.pythonhosted.org/packages/4b/79/9c2354bc01fcab52b1482a332759af54806c912c493d99a8aca1f9cab72d/hvac-0.10.0.tar.gz
pip install hvac-0.10.0.tar.gz

requests-2.23.0-py2.py3-none-any.whl
certifi-2019.11.28-py2.py3-none-any.whl
urllib3-1.25.8-py2.py3-none-any.whl
idna-2.9-py2.py3-none-any.whl
chardet-3.0.4-py2.py3-none-any.whl



curl -OL https://files.pythonhosted.org/packages/5c/40/3bed01fc17e2bb1b02633efc29878dfa25da479ad19a69cfb11d2b88ea8e/jmespath-0.9.5.tar.gz
pip install jmespath-0.9.5.tar.gz


#curl -OL https://files.pythonhosted.org/packages/df/ed/bea598a87a8f7e21ac5bbf464102077c7102557c07db9ff4e207bd9f7806/setuptools-46.0.0.zip

#curl -OL https://files.pythonhosted.org/packages/16/8b/54a26c1031595e5edd0e616028b922d78d8ffba8bc775f0a4faeada846cc/ruamel.yaml-0.16.10.tar.gz
#pip install ruamel.yaml-0.16.10.tar.gz



#cloud-utils-growpart for azure
curl -OL http://mirror.centos.org/centos/7/os/x86_64/Packages/cloud-utils-growpart-0.29-5.el7.noarch.rpm
sudo rpm -ivh cloud-utils-growpart-0.29-5.el7.noarch.rpm

#curl -OL http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/yum-utils-1.1.31-52.el7.noarch.rpm
#sudo rpm -ivh yum-utils-1.1.31-52.el7.noarch.rpm




#roles/kubernetes/preinstall/defaults/main.yml
  - curl
  - rsync
  - socat
  - unzip
  - e2fsprogs
  - xfsprogs
  - conntrack

#curl -OL http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/e2fsprogs-1.42.9-16.el7.x86_64.rpm
#sudo rpm -ivh e2fsprogs-1.42.9-16.el7.x86_64.rpm

#curl -OL http://rpmfind.net/linux/centos/7.7.1908/os/x86_64/Packages/xfsprogs-4.5.0-20.el7.x86_64.rpm
#sudo rpm -ivh xfsprogs-4.5.0-20.el7.x86_64.rpm








---

### haproxy



### docker registry
docker pull registry
docker run -d -p 5000:5000 --restart=always --name registry registry

sudo vi /etc/docker/daemon.json
{
    "insecure-registries": ["10.0.1.9:5000"]
}

sudo service docker restart
docker info


docker pull gcr.io/google-containers/kube-controller-manager:v1.16.6			
docker pull gcr.io/google-containers/kube-apiserver:v1.16.6                      
docker pull gcr.io/google-containers/kube-proxy:v1.16.6                          
docker pull gcr.io/google-containers/kube-scheduler:v1.16.6                      
docker pull calico/node:v3.11.1                                                  
docker pull calico/cni:v3.11.1                                                   
docker pull calico/kube-controllers:v3.11.1                                      
docker pull gcr.io/google-containers/k8s-dns-node-cache:1.15.8                   
docker pull coredns/coredns:1.6.0                                                
docker pull weaveworks/weave-kube:2.5.2                                          
docker pull weaveworks/weave-npc:2.5.2                                           
docker pull gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0 
docker pull gcr.io/google_containers/kubernetes-dashboard-amd64:v1.10.1          
docker pull quay.io/coreos/etcd:v3.3.10                                          
docker pull gcr.io/google-containers/pause:3.1                                   
docker pull gcr.io/google_containers/pause-amd64:3.1                             
docker pull lachlanevenson/k8s-helm:v3.1.0										  
docker pull gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0 


docker image tag gcr.io/google-containers/kube-controller-manager:v1.16.6				10.0.1.9:5000/google-containers/kube-controller-manager:v1.16.6
docker image tag gcr.io/google-containers/kube-apiserver:v1.16.6                        10.0.1.9:5000/google-containers/kube-apiserver:v1.16.6
docker image tag gcr.io/google-containers/kube-proxy:v1.16.6                            10.0.1.9:5000/google-containers/kube-proxy:v1.16.6
docker image tag gcr.io/google-containers/kube-scheduler:v1.16.6                        10.0.1.9:5000/google-containers/kube-scheduler:v1.16.6
docker image tag calico/node:v3.11.1                                                    10.0.1.9:5000/calico/node:v3.11.1
docker image tag calico/cni:v3.11.1                                                     10.0.1.9:5000/calico/cni:v3.11.1
docker image tag calico/kube-controllers:v3.11.1                                        10.0.1.9:5000/calico/kube-controllers:v3.11.1
docker image tag gcr.io/google-containers/k8s-dns-node-cache:1.15.8                     10.0.1.9:5000/google-containers/k8s-dns-node-cache:1.15.8
docker image tag coredns/coredns:1.6.0                                                  10.0.1.9:5000/coredns/coredns:1.6.0
docker image tag weaveworks/weave-kube:2.5.2                                            10.0.1.9:5000/weaveworks/weave-kube:2.5.2
docker image tag weaveworks/weave-npc:2.5.2                                             10.0.1.9:5000/weaveworks/weave-npc:2.5.2
docker image tag gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0   10.0.1.9:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
docker image tag gcr.io/google_containers/kubernetes-dashboard-amd64:v1.10.1            10.0.1.9:5000/google_containers/kubernetes-dashboard-amd64:v1.10.1
docker image tag quay.io/coreos/etcd:v3.3.10                                            10.0.1.9:5000/coreos/etcd:v3.3.10
docker image tag gcr.io/google-containers/pause:3.1                                     10.0.1.9:5000/google-containers/pause:3.1
docker image tag gcr.io/google_containers/pause-amd64:3.1                               10.0.1.9:5000/google_containers/pause-amd64:3.1
docker image tag lachlanevenson/k8s-helm:v3.1.0										    10.0.1.9:5000/lachlanevenson/k8s-helm:v3.1.0
docker image tag gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0   10.0.1.9:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0


docker push 10.0.1.9:5000/google-containers/kube-controller-manager:v1.16.6
docker push 10.0.1.9:5000/google-containers/kube-apiserver:v1.16.6
docker push 10.0.1.9:5000/google-containers/kube-proxy:v1.16.6
docker push 10.0.1.9:5000/google-containers/kube-scheduler:v1.16.6
docker push 10.0.1.9:5000/calico/node:v3.11.1
docker push 10.0.1.9:5000/calico/cni:v3.11.1
docker push 10.0.1.9:5000/calico/kube-controllers:v3.11.1
docker push 10.0.1.9:5000/google-containers/k8s-dns-node-cache:1.15.8
docker push 10.0.1.9:5000/coredns/coredns:1.6.0
docker push 10.0.1.9:5000/weaveworks/weave-kube:2.5.2
docker push 10.0.1.9:5000/weaveworks/weave-npc:2.5.2
docker push 10.0.1.9:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
docker push 10.0.1.9:5000/google_containers/kubernetes-dashboard-amd64:v1.10.1
docker push 10.0.1.9:5000/coreos/etcd:v3.3.10
docker push 10.0.1.9:5000/google-containers/pause:3.1
docker push 10.0.1.9:5000/google_containers/pause-amd64:3.1	
docker push 10.0.1.9:5000/lachlanevenson/k8s-helm:v3.1.0
docker push 10.0.1.9:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0


### docker setting

https://waspro.tistory.com/557


 vi inventory/mycluster/group_vars/all/docker.yml
```
## An obvious use case is allowing insecure-registry access to self hosted registries.
## Can be ipaddress and domain_name.
## example define 172.19.16.11 or mirror.registry.io
docker_insecure_registries:
#   - mirror.registry.io
  - 10.0.1.9:5000
```  

vi inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml 
```
# kubernetes image repo define
gcr_image_repo: "10.0.1.9:5000"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
docker_image_repo: "10.0.1.9:5000"

# quay image repo define
quay_image_repo: "10.0.1.9:5000"
```


https://waspro.tistory.com/562
https://waspro.tistory.com/561
https://docs.docker.com/install/linux/docker-ce/ubuntu/
https://medium.com/sqooba/create-your-own-custom-and-authenticated-apt-repository-1e4a4cf0b864



proxy1 server
docker hub 구성
1. nginx설치
sudo apt install nginx
DocRott 변경 - /home/gs/sw/nginx

2. docker 설정
cd /home/gs/sw/nginx
wget -r https://download.docker.com/linux/centos/7/x86_64/stable/repodata/
stable만 남기고 삭제
mv download.docker.com docker-ce


mkdir -p /home/gs/sw/nginx/docker-ce/linux/centos/7/x86_64/stable/Packages
mkdir -p /home/gs/sw/nginx/docker-ce/linux/centos/7/x86_64/stable/repodata
cd /home/gs/sw/nginx/docker-ce/linux/centos
curl -OL https://download.docker.com/linux/centos/gpg
cd /home/gs/sw/nginx/docker-ce/linux/centos/7/x86_64/stable/repodata
curl -OL https://download.docker.com/linux/centos/7/x86_64/stable/repodata/repomd.xml
cd /home/gs/sw/nginx/docker-ce/linux/centos/7/x86_64/stable/Packages


cd /home/gs/sw/nginx
mkdir -p /home/gs/sw/nginx/kubernetes-release/release/v1.16.6/bin/linux/amd64
mkdir -p /home/gs/sw/nginx/coreos/etcd/releases/download/v3.3.10
mkdir -p /home/gs/sw/nginx/containernetworking/plugins/releases/download/v0.8.3
mkdir -p /home/gs/sw/nginx/projectcalico/calicoctl/releases/download/v3.11.1
mkdir -p /home/gs/sw/nginx/kubernetes-sigs/cri-tools/releases/download/v1.16.1

curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubelet -o kubernetes-release/release/v1.16.6/bin/linux/amd64/kubelet
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubectl -o kubernetes-release/release/v1.16.6/bin/linux/amd64/kubectl
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubeadm -o kubernetes-release/release/v1.16.6/bin/linux/amd64/kubeadm
curl https://github.com/coreos/etcd/releases/download/v3.3.10/etcd-v3.3.10-linux-amd64.tar.gz -o coreos/etcd/releases/download/v3.3.10/etcd-v3.3.10-linux-amd64.tar.gz
curl https://github.com/containernetworking/plugins/releases/download/v0.8.3/cni-plugins-linux-amd64-v0.8.3.tgz -o containernetworking/plugins/releases/download/v0.8.3/cni-plugins-linux-amd64-v0.8.3.tgz
curl https://github.com/projectcalico/calicoctl/releases/download/v3.11.1/calicoctl-linux-amd64 -o projectcalico/calicoctl/releases/download/v3.11.1/calicoctl-linux-amd64
curl https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.16.1/crictl-v1.16.1-linux-amd64.tar.gz -o kubernetes-sigs/cri-tools/releases/download/v1.16.1/crictl-v1.16.1-linux-amd64.tar.gz


kubelet_download_url: "http://10.0.1.9/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
kubectl_download_url: "http://10.0.1.9/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
kubeadm_download_url: "http://10.0.1.9/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
etcd_download_url: "http://10.0.1.9/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
cni_download_url: "https://10.0.1.9/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
calicoctl_download_url: "http://10.0.1.9/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
crictl_download_url: "http://10.0.1.9/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"



* docker repository 경로를 내부망 경로로 변경
kubespray/roles/container-engine/docker/defaults/main.yml
# CentOS/RedHat docker-ce repo
#docker_rh_repo_base_url: 'https://download.docker.com/linux/centos/7/$basearch/stable'
#docker_rh_repo_gpgkey: 'https://download.docker.com/linux/centos/gpg'
docker_rh_repo_base_url: 'http://10.0.1.9/docker-ce/linux/centos/7/$basearch/stable'
docker_rh_repo_gpgkey: 'http://10.0.1.9/docker-ce/linux/centos/gpg'

# CentOS/RedHat Extras repo
#extras_rh_repo_base_url: "http://mirror.centos.org/centos/$releasever/extras/$basearch/"
#extras_rh_repo_gpgkey: "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7"
extras_rh_repo_base_url: "http://10.0.1.9/docker-mirror/centos/$releasever/extras/$basearch/"
extras_rh_repo_gpgkey: "http://10.0.1.9/docker-mirror/centos/RPM-GPG-KEY-CentOS-7"



# flag to enable/disable docker cleanup
docker_orphan_clean_up: true


* docker file에 대한 gpg check disable
kubespray/roles/container-engine/docker/tasks/main.yml
gpgcheck: yes  -> gpgcheck: no

* 주요 다운로드 URL을 내부망으로 변경
kubespray/roles/download/defaults/main.yml

# gcr and kubernetes image repo define
#gcr_image_repo: "gcr.io"
gcr_image_repo: "10.0.1.9:5000"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
#docker_image_repo: "docker.io"
docker_image_repo: "10.0.1.9:5000"

# quay image repo define
#quay_image_repo: "quay.io"
quay_image_repo: "10.0.1.9:5000"


# Download URLs
#kubelet_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
#kubectl_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
#kubeadm_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
#etcd_download_url: "https://github.com/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
#cni_download_url: "https://github.com/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
#calicoctl_download_url: "https://github.com/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
#crictl_download_url: "https://github.com/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"

kubelet_download_url: "http://10.0.1.9/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
kubectl_download_url: "http://10.0.1.9/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
kubeadm_download_url: "http://10.0.1.9/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
etcd_download_url: "http://10.0.1.9/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
cni_download_url: "https://10.0.1.9/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
calicoctl_download_url: "http://10.0.1.9/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
crictl_download_url: "http://10.0.1.9/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"



* etcd 인증서 체크 disable
kubespray/roles/etcd/tasks/check_certs.yml
sync_certs: true  -> sync_certs: false

* docker registry에 대한 insecure registries를 추가
kubespray/inventory/mycluster/group_vars/all/docker.yml
docker_insecure_registries:
  - 10.0.1.9:5000

* docker registry 주소 설정
kubespray/inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml
# kubernetes image repo define
gcr_image_repo: "10.0.1.9:5000"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
docker_image_repo: "10.0.1.9:5000"

# quay image repo define
quay_image_repo: "10.0.1.9:5000"



fatal: [node1]: UNREACHABLE! => {"changed": false, "msg": "SSH Error: data could not be sent to remote host \"10.0.1.4\". Make sure this host can be reached over ssh", "unreachable": true}





### kubenetes install

mkdir /tmp/releases
cd /tmp/releases

curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubelet -o kubelet-v1.16.6.tar.gz
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubectl -o kubectl-v1.16.6.tar.gz
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubeadm -o kubeadm-v1.16.6.tar.gz
curl https://github.com/coreos/etcd/releases/download/v3.3.10/etcd-v3.3.10-linux-amd64.tar.gz -o etcd-v3.3.10-linux-amd64.tar.gz
curl https://github.com/containernetworking/plugins/releases/download/v0.8.3/cni-plugins-linux-amd64-v0.8.3.tgz -o cni-plugins-linux-amd64-v0.8.3.tgz 
curl https://github.com/projectcalico/calicoctl/releases/download/v3.11.1/calicoctl-linux-amd64 -o calicoctl-linux-amd64



### kubespray install
ANSIBLE_VERBOSITY=4 
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml --flush-cache 
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml --flush-cache
ansible-playbook -i inventory/mycluster/hosts.yml reset.yml --flush-cache

### error
fatal: [node2]: FAILED! => {"attempts": 1, "changed": false, "msg": "https://download.docker.com/linux/centos/7/x86_64/stable/repodata/repomd.xml: [Errno 14] curl#7 - \"Failed to connect to 2600:9000:2150:5800:3:db06:4200:93a1: Network is unreachable\"\nTrying other mirror.


10.0.1.4
10.0.1.5
10.0.1.6
10.0.1.7
10.0.1.8

10.0.1.9
10.0.1.10
