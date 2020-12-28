https://docs.genesys.com/Documentation/GCXI/9.0.0/Dep/DockerOffline


## Download and Install Docker

```
export DOCKERDIR=/home/opc/docker

yumdownloader --assumeyes --destdir=$DOCKERDIR/yum --resolve yum-utils
yumdownloader --assumeyes --destdir=$DOCKERDIR/dm --resolve device-mapper-persistent-data
yumdownloader --assumeyes --destdir=$DOCKERDIR/lvm2 --resolve lvm2
yumdownloader --assumeyes --destdir=$DOCKERDIR/docker-ce --resolve docker-ce
yumdownloader --assumeyes --destdir=$DOCKERDIR/se --resolve container-selinux
```

```
$ tree docker/
docker/
├── dm
│   └── device-mapper-persistent-data-0.8.5-3.el7_9.2.x86_64.rpm
├── docker-ce
│   ├── containerd.io-1.4.3-3.1.el7.x86_64.rpm
│   ├── container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
│   ├── docker-ce-20.10.1-3.el7.x86_64.rpm
│   ├── docker-ce-cli-20.10.1-3.el7.x86_64.rpm
│   ├── docker-ce-rootless-extras-20.10.1-3.el7.x86_64.rpm
│   ├── fuse3-libs-3.6.1-4.el7.x86_64.rpm
│   ├── fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm
│   └── slirp4netns-0.4.3-4.el7_8.x86_64.rpm
├── lvm2
│   ├── device-mapper-1.02.170-6.el7_9.3.x86_64.rpm
│   ├── device-mapper-event-1.02.170-6.el7_9.3.x86_64.rpm
│   ├── device-mapper-event-libs-1.02.170-6.el7_9.3.x86_64.rpm
│   ├── device-mapper-libs-1.02.170-6.el7_9.3.x86_64.rpm
│   ├── lvm2-2.02.187-6.el7_9.3.x86_64.rpm
│   └── lvm2-libs-2.02.187-6.el7_9.3.x86_64.rpm
├── se
│   └── container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
└── yum
    └── yum-utils-1.1.31-54.el7_8.noarch.rpm
```



### Procedure: Install Docker (offline machine)


```
yum remove docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine
```





## Download and Install Kubernetes

### Procedure: Download Kubernetes utilities (online machine)

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```


```
yum list --showduplicates kubeadm --disableexcludes=kubernetes
확인 후 버전 선택
```
```
export RPMDIR=/home/opc/k8s

yumdownloader --assumeyes --destdir=$RPMDIR --resolve yum-utils kubeadm-1.19.6 kubelet-1.19.6 kubectl-1.19.6 ebtables
```

### Procedure: Install Kubernetes utilities (offline machine)




## Download and Install Kubernetes Images

### Procedure: Download Kubernetes Images (online machine)

```
docker pull k8s.gcr.io/kube-apiserver:v1.19.6 
docker save k8s.gcr.io/kube-apiserver:v1.19.6 > kube-apiserver_v1.19.6.tar

docker pull k8s.gcr.io/kube-controller-manager:v1.19.6 
docker save k8s.gcr.io/kube-controller-manager:v1.19.6 > kube-controller-manager_v1.19.6.tar

docker pull k8s.gcr.io/kube-scheduler:v1.19.6 
docker save k8s.gcr.io/kube-scheduler:v1.19.6 > kube-scheduler_v1.19.6.tar

docker pull k8s.gcr.io/kube-proxy:v1.19.6 
docker save k8s.gcr.io/kube-proxy:v1.19.6 > kube-proxy_v1.19.6.tar

docker pull k8s.gcr.io/pause:3.2 
docker save k8s.gcr.io/pause:3.2 > pause_3.2.tar

docker pull k8s.gcr.io/etcd:3.4.13-0 
docker save k8s.gcr.io/etcd:3.4.13-0 > etcd_3.4.13-0.tar

docker pull k8s.gcr.io/coredns:1.7.0 
docker save k8s.gcr.io/coredns:1.7.0 > coredns_1.7.0.tar

```