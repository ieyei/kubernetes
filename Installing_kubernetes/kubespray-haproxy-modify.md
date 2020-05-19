# Kuberspay haproxy 정보 변경

**system info**

node1(192.168.56.111) : master1

node2(192.168.56.112) : master2

node3(192.168.56.113) : worker1, haproxy
 
node4(192.168.56.114) : worker2  




**작업내용** : haproxy를 node3(192.168.56.113) 에서 node4(192.168.56.114) 로 이전 설치 & domain name로 설정



## haproxy 구성(node4)

1. haproxy install

   ```
   sudo apt install haproxy
   ```

2. Configure HAProxy

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

3. haproxy.cfg에 아래 내용 추가(/etc/haproxy/haproxy.cfg)

   ```
   listen kubernetes-apiserver-https
     bind 192.168.56.114:8383
     mode tcp
     option log-health-checks
     timeout client 3h
     timeout server 3h
     server master1 192.168.56.111:6443 check check-ssl verify none inter 10000
     server master2 192.168.56.112:6443 check check-ssl verify none inter 10000
     balance roundrobin
   ```

   참조 : [HA endpoints for K8s](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ha-mode.md)

4. verify configuration

   ```
   haproxy -c -f /etc/haproxy/haproxy.cfg
   ```

5. restart HAProxy service

   ```
   sudo service haproxy restart
   ```



## host 정보 업데이트

대상서버 : All

```
echo "192.168.56.114 haproxy" >> /etc/hosts

/etc/init.d/networking restart
```



proxy가 있을 경우 noproxy에 haproxy 추가!



## 설정 파일 변경

### 대상 서버 : master nodes(node1, node2)

대상 파일(/etc/kubernetes)

* admin.conf

* controller-manager.conf

* kubeadm-config.yaml

* kubelet.conf

* scheduler.conf



변경 내용

```
192.168.56.113:8383 --> haproxy:8383
```

kubeadm-config.yaml  파일은 추가 변경 필요

```
certSANs:
- 192.168.56.113  --> haproxy
```



### 대상 서버 : worker nodes(node3, node4)

대상 파일(/etc/kubernetes)

* kubeadm-client.conf
* kubelet.conf



변경 내용

```
192.168.56.113:8383 --> haproxy:8383
```



## config map 수정

```
kubectl edit cm -n kube-public cluster-info
kubectl edit cm -n kube-system kube-proxy
kubectl edit cm -n kube-system kubeadm-config
```



변경 내용

```
192.168.56.113:8383 --> haproxy:8383
```



controller manager, scheduler 반영(restart)

```sh
kubectl delete po -n kube-system kube-controller-manager-node1
kubectl delete po -n kube-system kube-controller-manager-node2

kubectl delete po -n kube-system kube-scheduler-node1
kubectl delete po -n kube-system kube-scheduler-node2
```



## apiserver 인증서 갱신

kubeadm 통해서 인증서 갱신

```sh
cd /etc/kubernetes/ssl
mv apiserver.crt apiserver.crt.old
mv apiserver.key apiserver.key.old

cd /etc/kubernetes
kubeadm init phase certs apiserver --config kubeadm-config.yaml
```

확인

```sh
openssl x509 -text -noout -in /etc/kubernetes/ssl/apiserver.crt
```



apiserver restart

```
kubectl delete po -n kube-system kube-apiserver-node1
kubectl delete po -n kube-system kube-apiserver-node2
```



## 설정 파일 복사

```
cp /etc/kubernetes/admin.conf /root/.kube/config
```

