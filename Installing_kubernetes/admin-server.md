# Admin Server 구성

OS: RHEL7.7

Admin Server : 10.0.1.14



Admin Server 역할

* Kubernetes 설치 파일 Repo
* Docker Repo
* Docker Registry
* pip Repo
* haproxy


## Firewall

```
setenforce Permissive
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
```

https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/



## Host File update

```
echo "10.0.1.14 admin" >> /etc/hosts
```

## Download files from storage
```
mkdir -p /var/www
cd /var/www
```

**Download files**
images_k8s.tar          # k8s images
kubespray-offline.tar   # offline files
registry.tar            # docker registry image
yum_rhel76.tar          # files for rhel 7.6

```
tar -xf kubespray-offline.tar -C /var/www
tar xf yum_rhel76.tar -C /var/www
```


## Nginx

1. nginx설치

참고 - https://www.nginx.com/resources/wiki/start/topics/tutorials/install/


file 저장 디렉토리

/var/www/



nginx install

```
yum localinstall -y /var/www/repo/nginx-1.16.1-1.el7.ngx.x86_64.rpm
```



nginx Document Root 위치 변경

sudo vi /etc/nginx/conf.d/default.conf

```
    location / {
        #root   /usr/share/nginx/html;
        root   /var/www;
        index  index.html index.htm;
    }
```



nginx start

```
sudo systemctl start nginx
sudo systemctl enable nginx
```



방화벽 80 포트 오픈

```
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
```

https://www.godaddy.com/garage/how-to-install-and-configure-nginx-on-centos-7/



## Kubernetes preinstall files

필요한 파일들은 `/var/www/repo` 에 위치.



## Kubernetes files

필요한 파일들은 `/var/www` 에 위치.



## Kubespray files

필요한 파일들은 `/var/www` 에 위치.



## Docker Repository

필요한 파일들은 `/var/www/` 에 위치.



## Docker Registry

docker install

```
yum localinstall /var/www/repo/docker-ce-18.09.7-3.el7.x86_64.rpm
```



docker registry 설치 & http 통신위한 설정

```
service docker start
docker pull registry

docker run -d -p 5000:5000 --restart=always --name registry registry

sudo vi /etc/docker/daemon.json
{
    "insecure-registries": ["admin:5000"]
}

service docker restart
docker info

systemctl enable nginx
```



## HAproxy

install

```
yum localinstall /var/www/repo/haproxy-1.5.18-9.el7.x86_64.rpm
```



Configure HAProxy

```
$ sudo vi /etc/sysctl.conf

net.ipv4.ip_nonlocal_bind=1
net.ipv4.ip_forward=1

$ sudo sysctl -p
```

시스템 시작 시 자동실행

```
echo "ENABLED=1" >> /etc/default/haproxy
```



vi /etc/haproxy/haproxy.cfg

```
...
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend  main *:16443
    acl url_static       path_beg       -i /static /images /javascript /stylesheets
    acl url_static       path_end       -i .jpg .gif .png .css .js

    use_backend static          if url_static
    default_backend             app
    mode tcp

#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------
backend static
    balance     roundrobin
    server      static 127.0.0.1:4331 check

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend app
    mode tcp
    balance     roundrobin
    server  app1 10.0.1.15:6443  #master node1
    server  app2 10.0.1.16:6443  #master node2
    server  app3 10.0.1.17:6443  #master node3

```



verify configuration 

```
haproxy -c -f /etc/haproxy/haproxy.cfg
```



restart HAProxy service

```
sudo service haproxy restart
```





---



## Files 준비

### Nginx

nginx 설치를 위해 repo 추가

vi /etc/yum.repo.d/nginx.repo

```
[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/rhel/7/$basearch/
gpgcheck=0
enabled=1
```



```
yum install nginx --downloadonly --downloaddir=/var/www/repo
```



### Kubernetes preinstall files

**default files for k8s**

$KUBESPRAY/roles/kubernetes/preinstall/defaults/main.yml 참조

```
yum install libselinux-python device-mapper-libs ebtables nss openssl curl rsync socat unzip e2fsprogs xfsprogs conntrack yum-utils \
 --downloadonly --downloaddir=/var/www/repo 
```

**epel-release**

```
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm --downloadonly --downloaddir=/var/www/repo 

#cp /var/tmp/yum-root-eMQu26/epel-release-latest-7.noarch.rpm /var/www/repo
#yum localinstall /var/www/repo/epel-release-latest-7.noarch.rpm 
```

**ansible-2.7.16**

```
curl https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.7.16-1.el7.ans.noarch.rpm -o /var/www/repo/ansible-2.7.16-1.el7.ans.noarch.rpm
#yum localinstall /var/www/repo/ansible-2.7.16-1.el7.ans.noarch.rpm
```

**python36,pip36,pip**

```
yum install python36 python36-pip  --downloadonly --downloaddir=/var/www/repo
yum install python-pip  --downloadonly --downloaddir=/var/www/repo
#yum localinstall /var/www/repo/python2-pip-8.1.2-12.el7.noarch.rpm
```



### Kubernetes files

필요한 파일 버전 정보 확인

$KUBESPRAY/roles/download/defaults/main.yaml

```
...
# Versions
kube_version: v1.16.6
kubeadm_version: "{{ kube_version }}"
etcd_version: v3.3.12

calico_version: "v3.11.1"
calico_ctl_version: "v3.11.1"
calico_cni_version: "v3.11.1"
calico_policy_version: "v3.11.1"
calico_typha_version: "v3.11.1"
typha_enabled: false

flannel_version: "v0.11.0"
flannel_cni_version: "v0.3.0"

cni_version: "v0.8.3"

weave_version: 2.5.2
pod_infra_version: 3.1
contiv_version: 1.2.1
cilium_version: "v1.7.1"
kube_ovn_version: "v0.6.0"
kube_router_version: "v0.2.5"
multus_version: "v3.2.1"

crictl_supported_versions:
  v1.17: "v1.17.0"
  v1.16: "v1.16.1"
  v1.15: "v1.15.0"
crictl_version: "{{ crictl_supported_versions[kube_major_version] }}"
...
```



kubernetes 설치를 위한 file download

```
cd /var/www
mkdir -p /var/www/kubernetes-release/release/v1.16.6/bin/linux/amd64
mkdir -p /var/www/coreos/etcd/releases/download/v3.3.10
mkdir -p /var/www/containernetworking/plugins/releases/download/v0.8.3
mkdir -p /var/www/projectcalico/calicoctl/releases/download/v3.11.1
mkdir -p /var/www/kubernetes-sigs/cri-tools/releases/download/v1.16.1

curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubelet -o kubernetes-release/release/v1.16.6/bin/linux/amd64/kubelet
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubectl -o kubernetes-release/release/v1.16.6/bin/linux/amd64/kubectl
curl https://storage.googleapis.com/kubernetes-release/release/v1.16.6/bin/linux/amd64/kubeadm -o kubernetes-release/release/v1.16.6/bin/linux/amd64/kubeadm
curl https://github.com/coreos/etcd/releases/download/v3.3.10/etcd-v3.3.10-linux-amd64.tar.gz -o coreos/etcd/releases/download/v3.3.10/etcd-v3.3.10-linux-amd64.tar.gz
curl https://github.com/containernetworking/plugins/releases/download/v0.8.3/cni-plugins-linux-amd64-v0.8.3.tgz -o containernetworking/plugins/releases/download/v0.8.3/cni-plugins-linux-amd64-v0.8.3.tgz
curl https://github.com/projectcalico/calicoctl/releases/download/v3.11.1/calicoctl-linux-amd64 -o projectcalico/calicoctl/releases/download/v3.11.1/calicoctl-linux-amd64
curl https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.16.1/crictl-v1.16.1-linux-amd64.tar.gz -o kubernetes-sigs/cri-tools/releases/download/v1.16.1/crictl-v1.16.1-linux-amd64.tar.gz
```



### Kubespray files

kubespray 다운로드 & tar 파일 생성

```
cd /var/www
git clone https://github.com/kubernetes-sigs/kubespray.git

tar cf kubespray_origin.tar kubespray
```





### Docker Repository

download.docker.com

```
cd /var/www
wget -r https://download.docker.com/linux/centos/7/x86_64/stable/repodata/

#stable, gpg만 남기고 삭제
mv download.docker.com docker-ce
```



mirror.centos.org

```
cd /var/www
wget -r http://mirror.centos.org/centos/7/extras/x86_64/repodata/

#stable, gpg만 남기고 삭제
mv mirror.centos.org docker-mirror
```



### Docker Registry

yum repo 추가

```
 cd /etc/yum.repos.d
 
 curl -OL https://download.docker.com/linux/centos/docker-ce.repo
 
 yum update
 
 # 18.09.7-3.el7
 yum install docker-ce-18.09.7-3.el7 docker-ce-cli-18.09.7-3.el7 containerd.io \
 --downloadonly --downloaddir=/var/www/repo 
```



docker image pull

```
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
```

docker file save&load
```
docker images | sed '1d' | awk '{print $1 ":" $2}'
docker save -o images_k8s.tar $(docker images | sed '1d' | awk '{print $1 ":" $2}')
# upload files to azure
# download files from azure

docker load -i images_k8s.tar
```


docker tag

```
docker image tag gcr.io/google-containers/kube-controller-manager:v1.16.6				        admin:5000/google-containers/kube-controller-manager:v1.16.6
docker image tag gcr.io/google-containers/kube-apiserver:v1.16.6                        admin:5000/google-containers/kube-apiserver:v1.16.6
docker image tag gcr.io/google-containers/kube-proxy:v1.16.6                            admin:5000/google-containers/kube-proxy:v1.16.6
docker image tag gcr.io/google-containers/kube-scheduler:v1.16.6                        admin:5000/google-containers/kube-scheduler:v1.16.6
docker image tag calico/node:v3.11.1                                                    admin:5000/calico/node:v3.11.1
docker image tag calico/cni:v3.11.1                                                     admin:5000/calico/cni:v3.11.1
docker image tag calico/kube-controllers:v3.11.1                                        admin:5000/calico/kube-controllers:v3.11.1
docker image tag gcr.io/google-containers/k8s-dns-node-cache:1.15.8                     admin:5000/google-containers/k8s-dns-node-cache:1.15.8
docker image tag coredns/coredns:1.6.0                                                  admin:5000/coredns/coredns:1.6.0
docker image tag weaveworks/weave-kube:2.5.2                                            admin:5000/weaveworks/weave-kube:2.5.2
docker image tag weaveworks/weave-npc:2.5.2                                             admin:5000/weaveworks/weave-npc:2.5.2
docker image tag gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0   admin:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
docker image tag gcr.io/google_containers/kubernetes-dashboard-amd64:v1.10.1            admin:5000/google_containers/kubernetes-dashboard-amd64:v1.10.1
docker image tag quay.io/coreos/etcd:v3.3.10                                            admin:5000/coreos/etcd:v3.3.10
docker image tag gcr.io/google-containers/pause:3.1                                     admin:5000/google-containers/pause:3.1
docker image tag gcr.io/google_containers/pause-amd64:3.1                               admin:5000/google_containers/pause-amd64:3.1
docker image tag lachlanevenson/k8s-helm:v3.1.0										    admin:5000/lachlanevenson/k8s-helm:v3.1.0
docker image tag gcr.io/google-containers/cluster-proportional-autoscaler-amd64:1.6.0   admin:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0

```



docker push

```
docker push admin:5000/google-containers/kube-controller-manager:v1.16.6
docker push admin:5000/google-containers/kube-apiserver:v1.16.6
docker push admin:5000/google-containers/kube-proxy:v1.16.6
docker push admin:5000/google-containers/kube-scheduler:v1.16.6
docker push admin:5000/calico/node:v3.11.1
docker push admin:5000/calico/cni:v3.11.1
docker push admin:5000/calico/kube-controllers:v3.11.1
docker push admin:5000/google-containers/k8s-dns-node-cache:1.15.8
docker push admin:5000/coredns/coredns:1.6.0
docker push admin:5000/weaveworks/weave-kube:2.5.2
docker push admin:5000/weaveworks/weave-npc:2.5.2
docker push admin:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
docker push admin:5000/google_containers/kubernetes-dashboard-amd64:v1.10.1
docker push admin:5000/coreos/etcd:v3.3.10
docker push admin:5000/google-containers/pause:3.1
docker push admin:5000/google_containers/pause-amd64:3.1	
docker push admin:5000/lachlanevenson/k8s-helm:v3.1.0
docker push admin:5000/google-containers/cluster-proportional-autoscaler-amd64:1.6.0
```



### HAproxy

file download

```
yum install haproxy --downloadonly --downloaddir=/var/www/repo
```



### Yum repodata

**createrepo**

```
# files for creating repodata
yum install createrepo --downloadonly --downloaddir=/var/www/repo 

yum localinstall /var/www/repo/createrepo-0.9.9-28.el7.noarch.rpm

createrepo /var/www/repo
```



rpm 추가했을 때 빠른 반영을 위해 update 실행,  대상 서버들은 yum update 

```
createrepo /var/www/repo --update
```



### pip repo

directory 생성

```
mkdir -p /var/www/piprepo
cd /var/www/piprepo
```



ansible 설치에 필요한 파일

$KUBESPRAY/requirements.txt 참조

```
cd /var/www

vi requirements.txt
ansible==2.7.16
jinja2==2.10.1
netaddr==0.7.19
pbr==5.2.0
hvac==0.8.2
jmespath==0.9.4
ruamel.yaml==0.15.96
```



설치 파일 다운로드

```
pip install --download=/var/www/piprepo -r requirements.txt
```

