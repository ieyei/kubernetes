# Admin Server 구성



```
yum update
```



```
setenforce Permissive
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sudo sed -i --follow-symlinks 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
```







https://www.tecmint.com/setup-local-http-yum-repository-on-centos-7/



## Nginx

1. nginx설치

https://www.nginx.com/resources/wiki/start/topics/tutorials/install/



nginx 설치를 위해 repo 추가

vi /etc/yum.repo.d/nginx.repo

```
[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/rhel/7/$basearch/
gpgcheck=0
enabled=1
```



file 저장 디렉토리

```
mkdir -p /var/www/repo
```



nginx install

```
yum install nginx --downloadonly --downloaddir=/var/www/repo
yum localinstall /var/www/repo/nginx-1.16.1-1.el7.ngx.x86_64.rpm
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



```
# files for kubernetes
yum install libselinux-python device-mapper-libs ebtables nss openssl curl rsync socat unzip e2fsprogs xfsprogs conntrack yum-utils \
 --downloadonly --downloaddir=/var/www/repo 
```



**epel-release**

```
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm --downloadonly --downloaddir=/var/www/repo 

cp /var/tmp/yum-root-eMQu26/epel-release-latest-7.noarch.rpm .

yum localinstall /var/www/repo/epel-release-latest-7.noarch.rpm 

```

**ansible**

```
yum install ansible --downloadonly --downloaddir=/var/www/repo 

#yum localinstall /var/www/repo/ansible-2.9.3-1.el7.noarch.rpm
```



```
yum install python36 python36-pip  --downloadonly --downloaddir=/var/www/repo
yum install python-pip  --downloadonly --downloaddir=/var/www/repo
yum localinstall /var/www/repo/python2-pip-8.1.2-12.el7.noarch.rpm
```







**createrepo**

```
# files for creating repodata
yum install createrepo --downloadonly --downloaddir=/var/www/repo 

yum localinstall /var/www/repo/createrepo-0.9.9-28.el7.noarch.rpm

createrepo /var/www/repo
```

rpm 추가했을 때 createrepo를 다시해줘야 하며,  대상 서버들은 yum update 필요!



```
createrepo --update
```





## Docker Repository

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
wget -r http://mirror.centos.org/centos/7/extras/x86_64//repodata/

#stable, gpg만 남기고 삭제
mv mirror.centos.org docker-mirror
```



## Docker Registry

yum repo 추가

```
 cd /etc/yum.repos.d
 
 curl -OL https://download.docker.com/linux/centos/docker-ce.repo
 
 yum update
 
 # 18.09.7-3.el7
 yum install docker-ce-18.09.7-3.el7 docker-ce-cli-18.09.7-3.el7 containerd.io \
 --downloadonly --downloaddir=/var/www/repo 
```



docker install

```
yum localinstall docker-ce-18.09.7-3.el7.x86_64.rpm
```



```
service docker restart
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

