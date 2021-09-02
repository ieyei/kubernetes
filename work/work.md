
Kubernetes Certification



환경

```sh
root@node1:~# kubectl get nodes
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   53m   v1.17.12
node2   Ready    master   52m   v1.17.12
node3   Ready    <none>   51m   v1.17.12
node4   Ready    <none>   51m   v1.17.12
node5   Ready    <none>   51m   v1.17.12
```



```sh
root@node1:~# kubectl get nodes
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   37m   v1.17.12
node2   Ready    master   37m   v1.17.12
node3   Ready    <none>   36m   v1.17.12
node4   Ready    <none>   36m   v1.17.12
node5   Ready    <none>   36m   v1.17.12

root@node1:~# kubeadm alpha certs check-expiration
[check-expiration] Reading configuration from the cluster...
[check-expiration] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
W0902 02:36:41.997281    3141 defaults.go:186] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]

CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Sep 02, 2022 01:58 UTC   364d                                    no      
apiserver                  Sep 02, 2022 01:57 UTC   364d            ca                      no      
apiserver-kubelet-client   Sep 02, 2022 01:57 UTC   364d            ca                      no      
controller-manager.conf    Sep 02, 2022 01:58 UTC   364d                                    no      
front-proxy-client         Sep 02, 2022 01:57 UTC   364d            front-proxy-ca          no      
scheduler.conf             Sep 02, 2022 01:58 UTC   364d                                    no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Aug 31, 2031 01:57 UTC   9y              no      
front-proxy-ca          Aug 31, 2031 01:57 UTC   9y              no      
root@node1:~# 
```



kubeadm-config 확인

```sh
root@node1:~# kubectl -n kube-system get cm kubeadm-config -oyaml
apiVersion: v1
data:
  ClusterConfiguration: |
    apiServer:
      certSANs:
      - kubernetes
      - kubernetes.default
      - kubernetes.default.svc
      - kubernetes.default.svc.cluster.local
      - 10.233.0.1
      - localhost
      - 127.0.0.1
      - node1
      - node2
      - lb-apiserver.kubernetes.local
      - 192.168.56.11
      - 192.168.56.12
      - 10.0.2.15
      - node1.cluster.local
      - node2.cluster.local
      extraArgs:
        allow-privileged: "true"
        anonymous-auth: "True"
        apiserver-count: "2"
        authorization-mode: Node,RBAC
        bind-address: 0.0.0.0
        enable-aggregator-routing: "False"
        endpoint-reconciler-type: lease
        insecure-port: "0"
        kubelet-preferred-address-types: InternalDNS,InternalIP,Hostname,ExternalDNS,ExternalIP
        profiling: "False"
        request-timeout: 1m0s
        runtime-config: ""
        service-node-port-range: 30000-32767
        storage-backend: etcd3
      extraVolumes:
      - hostPath: /usr/share/ca-certificates
        mountPath: /usr/share/ca-certificates
        name: usr-share-ca-certificates
        readOnly: true
      timeoutForControlPlane: 5m0s
    apiVersion: kubeadm.k8s.io/v1beta2
    certificatesDir: /etc/kubernetes/ssl
    clusterName: cluster.local
    controlPlaneEndpoint: 192.168.56.12:6443
    controllerManager:
      extraArgs:
        bind-address: 0.0.0.0
        configure-cloud-routes: "false"
        node-cidr-mask-size: "24"
        node-monitor-grace-period: 40s
        node-monitor-period: 5s
        pod-eviction-timeout: 5m0s
        profiling: "False"
        terminated-pod-gc-threshold: "12500"
    dns:
      imageRepository: k8s.gcr.io
      imageTag: 1.6.5
      type: CoreDNS
    etcd:
      external:
        caFile: /etc/ssl/etcd/ssl/ca.pem
        certFile: /etc/ssl/etcd/ssl/node-node2.pem
        endpoints:
        - https://192.168.56.11:2379
        - https://192.168.56.12:2379
        - https://192.168.56.13:2379
        keyFile: /etc/ssl/etcd/ssl/node-node2-key.pem
    imageRepository: k8s.gcr.io
    kind: ClusterConfiguration
    kubernetesVersion: v1.17.12
    networking:
      dnsDomain: cluster.local
      podSubnet: 10.233.64.0/18
      serviceSubnet: 10.233.0.0/18
    scheduler:
      extraArgs:
        bind-address: 0.0.0.0
  ClusterStatus: |
    apiEndpoints:
      node1:
        advertiseAddress: 192.168.56.11
        bindPort: 6443
      node2:
        advertiseAddress: 192.168.56.12
        bindPort: 6443
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: ClusterStatus
kind: ConfigMap
metadata:
  creationTimestamp: "2021-09-02T01:57:58Z"
  name: kubeadm-config
  namespace: kube-system
  resourceVersion: "459"
  selfLink: /api/v1/namespaces/kube-system/configmaps/kubeadm-config
  uid: ba11928e-d137-4cd7-b524-77c8665b5be2
```



인증서 갱신

```sh
root@node1:~# kubeadm alpha certs renew all
[renew] Reading configuration from the cluster...
[renew] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
W0902 02:50:05.606346   10356 defaults.go:186] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]

certificate embedded in the kubeconfig file for the admin to use and for kubeadm itself renewed
certificate for serving the Kubernetes API renewed
certificate for the API server to connect to kubelet renewed
certificate embedded in the kubeconfig file for the controller manager to use renewed
certificate for the front proxy client renewed
certificate embedded in the kubeconfig file for the scheduler manager to use renewed
```



```sh
root@node1:/etc/kubernetes# ls -l *.conf
-rw-r----- 1 root root 5465 Sep  2 02:50 admin.conf
-rw-r----- 1 root root 5501 Sep  2 02:50 controller-manager.conf
-rw-r----- 1 root root 5465 Sep  2 01:58 kubelet.conf
-rw-r----- 1 root root 5445 Sep  2 02:50 scheduler.conf


root@node1:~# kubeadm alpha certs check-expiration
[check-expiration] Reading configuration from the cluster...
[check-expiration] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
W0902 03:05:57.870602   19128 defaults.go:186] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]

CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Sep 02, 2022 02:50 UTC   364d                                    no      
apiserver                  Sep 02, 2022 02:50 UTC   364d            ca                      no      
apiserver-kubelet-client   Sep 02, 2022 02:50 UTC   364d            ca                      no      
controller-manager.conf    Sep 02, 2022 02:50 UTC   364d                                    no      
front-proxy-client         Sep 02, 2022 02:50 UTC   364d            front-proxy-ca          no      
scheduler.conf             Sep 02, 2022 02:50 UTC   364d                                    no      

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Aug 31, 2031 01:57 UTC   9y              no      
front-proxy-ca          Aug 31, 2031 01:57 UTC   9y              no    
```



