
구성 순서
1. Docker
2. Kubernetes
3. Kubernetes Images
4. Kubernetes Network
5. Deploy Cluster
6. Ingress Controller


# Offline Machines
## Install Docker
[Download Docker (Online Machine)](#Download-Docker)

1. Copy the Docker files from the online machine to the offline machine.
2. Uninstall any old docker software:
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

3. Set a directory
    ```
    export DOCKERDIR=/home/XXX/docker
    ```


4. Install yum utilities:
    ```
    yum install -y --cacheonly --disablerepo=* $DOCKERDIR/yum/*.rpm
    ```

5. Install Docker file drivers:
    ```
    yum install -y --cacheonly --disablerepo=* $DOCKERDIR/dm/*.rpm
    yum install -y --cacheonly --disablerepo=* $DOCKERDIR/lvm2/*.rpm
    ```

6. Install container-selinux:
    ```
    yum install -y --cacheonly --disablerepo=* $DOCKERDIR/se/*.rpm
    ```

7. Install Docker:
    ```
    yum install -y --cacheonly --disablerepo=* $DOCKERDIR/docker-ce/*.rpm
    ```

8. Modify docker configuration to change "data root"
    ```
    mkdir -p /data/docker
    vi /etc/docker/daemon.json
    {
        "data-root": "/data/docker"
    }
    ```

9. Enable and start docker service:
    ```
    systemctl enable docker
    systemctl start docker
    ```

10. Verify docker:
    ```
    systemctl status docker
    docker version    
    ```


## Install Kubernetes utilities
[Download Kubernetes utilities (Online Machine)](#Download-Kubernetes-utilities)

1. Copy the Kubernetes utilities files from the online machine to the offline machine.
2. Install Kubernetes:
    ```
    export K8SDIR=/home/XXX/k8s

    yum install -y --cacheonly --disablerepo=* $K8SDIR/*.rpm
    ``` 

3. Run kubeadm, which returns a list of required images:
    ```
    $ kubeadm config images list
    I1228 03:20:35.004280    3930 version.go:252] remote version is much newer: v1.20.1; falling    back to: stable-1.19
    W1228 03:20:35.101328    3930 configset.go:348] WARNING: kubeadm cannot validate component  configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
    k8s.gcr.io/kube-apiserver:v1.19.6
    k8s.gcr.io/kube-controller-manager:v1.19.6
    k8s.gcr.io/kube-scheduler:v1.19.6
    k8s.gcr.io/kube-proxy:v1.19.6
    k8s.gcr.io/pause:3.2
    k8s.gcr.io/etcd:3.4.13-0
    k8s.gcr.io/coredns:1.7.0
    ```

## Load Kubernetes Images
[Download Kubernetes Images (Online Machine)](#Download-Kubernetes-Images)

1. Copy the Kubernetes images from the online machine to the offline machine.
2. Load the images:
    ```
    docker load < kube-apiserver_v1.19.6.tar
    docker load < kube-controller-manager_v1.19.6.tar
    docker load < kube-scheduler_v1.19.6.tar
    docker load < kube-proxy_v1.19.6.tar
    docker load < pause_3.2.tar
    docker load < etcd_3.4.13-0.tar
    docker load < coredns_1.7.0.tar
    ```

## Install Kubernetes networking files
[Download Kubernetes networking files (Online Machine)](#Download-Kubernetes-networking-files)

1. Copy the networking files from the online machine to the offline machine.
2. Load the networking image:
    ```
    docker load < flannel_v0.13.1-rc1.tar
    ```

## Deploy cluster
Perform steps 1-4 on each machine, and then complete subsequent steps as indicated:
1. Log in with root access.
2. Disable swap:
    ```
    swap -a
    ```

3. Ensure that SELinux is in permissive mode:
    ```
    setenforce 0
    sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
    ```

4. Ensure that the config option sysctl > net.bridge.bridge-nf-call-iptables is set to 1:
    ```
    cat <<EOF >  /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
    sysctl --system
    ```

5. Enable kubelet service:
    ```
    systemctl enable kubelet.service
    ```

> **Complete the preceding steps on each MASTER and WORKER node before continuing.**

5. **On the Master node only, create a cluster, deploy the Flannel network, and schedule pods:**
    1. Retrieve the version number for Kubernetes:
        ```
        kubectl version
        ```
        The Kubernetes version is displayed.
        
    2. Set up a Kubernetes cluster:
        ```
        kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.19.6 --ignore-preflight-errors=ImagePull
        ```
        Note that this command should include a string similar to: kubeadm join --token <token> <primary-ip>:<primary-port> --discovery-token-ca-cert-hash sha256:<hash>
        
        > **IMPORTANT**: This string is required in a later step.

    3. Verify the node is running:
        ```
        kubectl get nodes
        ```
    
    4. Configure kubectl to manage your cluster:
        ```
        grep -q "KUBECONFIG" ~/.bashrc || {
        echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc
        . ~/.bashrc
        }
        ```
    
    5. Deploy the Flannel overlay network on the Master Node:
        * Initiate the Flannel network:
            ```
            kubectl apply -f <destination path>/kube-flannel.yml
            ```

        * Check the pods status:
            ```
            kubectl get pods --all-namespaces
            ```

        * Optionally, to configure the cluster to schedule on the Master Node:
            ```
            kubectl taint nodes --all node-role.kubernetes.io/master-
            ```

6. **On the Worker Nodes only, join the Worker to the cluster:**
    Execute the following command:
    ```
    kubeadm join --token <token> <primary-ip>:<primary-port> --discovery-token-ca-cert-hash sha256:<hash>
    ```

7. **On the Master Node, verify nodes:**    
    Ensure that all nodes are in the ready state.
    ```
    kubectl get nodes
    ```



## Load NGINX images for Ingress
[Download NGINX images for Ingress (Online Machine)](#Download-NGINX-images-for-Ingress)


  
    




# Online Machine
## Download Docker
1. Execute the following command to configure YUM so it can download packages correctly:
    ```
    yum install -y yum-utils
    ```

2. Execute the following commands to install the Docker repository:
    ```
    yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    ```
3. Execute the following commands to download required files:       
    ```
    export DOCKERDIR=/home/opc/docker

    yumdownloader --assumeyes --destdir=$DOCKERDIR/yum --resolve yum-utils
    yumdownloader --assumeyes --destdir=$DOCKERDIR/dm --resolve     device-mapper-persistent-data
    yumdownloader --assumeyes --destdir=$DOCKERDIR/lvm2 --resolve lvm2
    yumdownloader --assumeyes --destdir=$DOCKERDIR/docker-ce --resolve docker-ce-19.03. 14-3.el7
    yumdownloader --assumeyes --destdir=$DOCKERDIR/se --resolve container-selinux
    ```

    ```
    # tree docker
    docker
    ├── dm
    │   └── device-mapper-persistent-data-0.8.5-3.el7_9.2.x86_64.rpm
    ├── docker-ce
    │   ├── containerd.io-1.4.3-3.1.el7.x86_64.rpm
    │   ├── container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
    │   ├── docker-ce-19.03.14-3.el7.x86_64.rpm
    │   └── docker-ce-cli-20.10.1-3.el7.x86_64.rpm
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

## Download Kubernetes utilities
1. Install the Kubernetes repository:
    ```
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.    google.com/yum/doc/rpm-package-key.gpg
    EOF
    ```

2. Download the Kubernetes utilities:
    ```
    # check versions
    yum list --showduplicates kubeadm --disableexcludes=kubernetes
    ```

    ```
    export RPMDIR=/home/opc/k8s

    yumdownloader --assumeyes --destdir=$RPMDIR --resolve yum-utils kubeadm-1.19.6 kubelet-1.19.6   kubectl-1.19.6 ebtables
    ```


## Download Kubernetes Images
1. Install Docker on each machine by following the instructions in the Docker installation documentation.
2.  Pull the image and save it as a TAR archive:
    ```
    docker pull k8s.gcr.io/kube-apiserver:v1.19.6
    docker pull k8s.gcr.io/kube-controller-manager:v1.19.6
    docker pull k8s.gcr.io/kube-scheduler:v1.19.6
    docker pull k8s.gcr.io/kube-proxy:v1.19.6
    docker pull k8s.gcr.io/pause:3.2
    docker pull k8s.gcr.io/etcd:3.4.13-0
    docker pull k8s.gcr.io/coredns:1.7.0

    docker save k8s.gcr.io/kube-apiserver:v1.19.6           > kube-apiserver_v1.19.6.tar
    docker save k8s.gcr.io/kube-controller-manager:v1.19.6  > kube-controller-manager_v1.19.6.tar
    docker save k8s.gcr.io/kube-scheduler:v1.19.6           > kube-scheduler_v1.19.6.tar
    docker save k8s.gcr.io/kube-proxy:v1.19.6               > kube-proxy_v1.19.6.tar
    docker save k8s.gcr.io/pause:3.2                        > pause_3.2.tar
    docker save k8s.gcr.io/etcd:3.4.13-0                    > etcd_3.4.13-0.tar
    docker save k8s.gcr.io/coredns:1.7.0                    > coredns_1.7.0.tar
    ```


## Download Kubernetes networking files
1. Download the yaml descriptor:
    ```
    wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    ```
2. Find the line that indicates the flannel image version:
    ```
    $ cat kube-flannel.yml | grep "image:"
        image: quay.io/coreos/flannel:v0.13.1-rc1
        image: quay.io/coreos/flannel:v0.13.1-rc1
    ```

3. Download and save the image:
    ```
    docker pull quay.io/coreos/flannel:v0.13.1-rc1
    docker save quay.io/coreos/flannel:v0.13.1-rc1 > flannel_v0.13.1-rc1.tar
    ```

## Download NGINX images for Ingress
