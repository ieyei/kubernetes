## TEST

### 시나리오

1. master2의 모든 인증서 및 설정 삭제
2. master2의 `kube-controller-manager`, `kube-apiserver`, `kube-scheduler` 컨테이너 삭제
3. master1에서 관련 인증서 및 설정 파일 master2로 복사
4. master2에서 삭제된 컨테이너가 정상적으로 동작하는지 모니터링
5. 클러스터 확인



```sh
root@node1:~# kubectl get nodes
NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   53m   v1.17.12
node2   Ready    master   52m   v1.17.12
node3   Ready    <none>   51m   v1.17.12
node4   Ready    <none>   51m   v1.17.12
node5   Ready    <none>   51m   v1.17.12
```



#### 1.master2의 모든 인증서 및 설정 삭제

Backup

```sh
mv /etc/kubernetes/ssl /etc/kubernetes/ssl.backup

mv /etc/kubernetes/admin.conf /etc/kubernetes/admin.conf.backup
mv /etc/kubernetes/controller-manager.conf /etc/kubernetes/controller-manager.conf.backup
mv /etc/kubernetes/kubelet.conf /etc/kubernetes/kubelet.conf.backup
mv /etc/kubernetes/scheduler.conf /etc/kubernetes/scheduler.conf.backup
```



#### 2.master2의 `kube-controller-manager`, `kube-apiserver`, `kube-scheduler` 컨테이너 삭제

```sh
root@node2:/etc/kubernetes# docker ps | grep -e kube-controller-manager -e kube-apiserver -e kube-scheduler
2e01ffb47a82        cb6db34dc164                  "kube-controller-man…"   About an hour ago   Up About an hour                        k8s_kube-controller-manager_kube-controller-manager-node2_kube-system_26376be84ff815a09507fe587d852a19_3
d33ad3edc4dd        90bd886d5f76                  "kube-scheduler --au…"   About an hour ago   Up About an hour                        k8s_kube-scheduler_kube-scheduler-node2_kube-system_8cae7d64e082749a678879695dc94338_2
e610c0d31eaf        18bef7765d63                  "kube-apiserver --ad…"   4 hours ago         Up 4 hours                              k8s_kube-apiserver_kube-apiserver-node2_kube-system_74ae7043f4152b44b85cf8f736ff9757_0
2e3859e4807d        k8s.gcr.io/pause:3.1          "/pause"                 4 hours ago         Up 4 hours                              k8s_POD_kube-apiserver-node2_kube-system_74ae7043f4152b44b85cf8f736ff9757_0
73ebe5188201        k8s.gcr.io/pause:3.1          "/pause"                 4 hours ago         Up 4 hours                              k8s_POD_kube-controller-manager-node2_kube-system_26376be84ff815a09507fe587d852a19_0
8a87d621e4fd        k8s.gcr.io/pause:3.1          "/pause"                 4 hours ago         Up 4 hours                              k8s_POD_kube-scheduler-node2_kube-system_8cae7d64e082749a678879695dc94338_0
```



해당 컨테이너 삭제

```sh
docker rm -f 2e01ffb47a82
docker rm -f d33ad3edc4dd
docker rm -f e610c0d31eaf
```



확인 : master2는 정상 동작하지 않음

```sh
root@node2:/etc/kubernetes# docker ps | grep -e kube-controller-manager -e kube-apiserver -e kube-scheduler
2e3859e4807d        k8s.gcr.io/pause:3.1          "/pause"                 4 hours ago         Up 4 hours                              k8s_POD_kube-apiserver-node2_kube-system_74ae7043f4152b44b85cf8f736ff9757_0
73ebe5188201        k8s.gcr.io/pause:3.1          "/pause"                 4 hours ago         Up 4 hours                              k8s_POD_kube-controller-manager-node2_kube-system_26376be84ff815a09507fe587d852a19_0
8a87d621e4fd        k8s.gcr.io/pause:3.1          "/pause"                 4 hours ago         Up 4 hours                              k8s_POD_kube-scheduler-node2_kube-system_8cae7d64e082749a678879695dc94338_0
```



#### 3.master1에서 관련 인증서 및 설정 파일 master2로 복사

```sh
# master1
# copy files from master1 to master2
gs@node1:~$ sudo scp /etc/kubernetes/*.conf gs@node2:/home/gs/
gs@node2's password: 
admin.conf                                                                                                                                   100% 5465     7.3MB/s   00:00    
controller-manager.conf                                                                                                                      100% 5501     4.5MB/s   00:00    
kubelet.conf                                                                                                                                 100% 5465     5.7MB/s   00:00    
scheduler.conf                                                                                                                               100% 5445     6.1MB/s   00:00    
gs@node1:~$ sudo scp -r /etc/kubernetes/ssl gs@node2:/home/gs/ssl
gs@node2's password: 
ca.key                                                                                                                                       100% 1675     1.4MB/s   00:00    
front-proxy-client.crt                                                                                                                       100% 1058     2.0MB/s   00:00    
apiserver-kubelet-client.key                                                                                                                 100% 1679     2.6MB/s   00:00    
ca.crt                                                                                                                                       100% 1025     1.9MB/s   00:00    
sa.key                                                                                                                                       100% 1679     2.7MB/s   00:00    
sa.pub                                                                                                                                       100%  451   711.1KB/s   00:00    
apiserver.key                                                                                                                                100% 1675     1.6MB/s   00:00    
apiserver-kubelet-client.crt                                                                                                                 100% 1099     1.9MB/s   00:00    
front-proxy-ca.key                                                                                                                           100% 1679     2.0MB/s   00:00    
front-proxy-ca.crt                                                                                                                           100% 1038     1.7MB/s   00:00    
front-proxy-client.key                                                                                                                       100% 1675     1.6MB/s   00:00    
apiserver.crt                                                                                                                                100% 1537     1.1MB/s   00:00    

# master2
gs@node2:~$ sudo cp *.conf /etc/kubernetes/ 
gs@node2:~$ sudo cp -r ssl /etc/kubernetes/

```





#### 4.master2에서 삭제된 컨테이너가 정상적으로 동작하는지 모니터링

Watch 명령어를 이용하여 삭제된 컨테이너가 되살아 나는지 확인

```sh
root@node2:/etc/kubernetes# watch "docker ps | grep -e kube-controller-manager -e kube-apiserver -e kube-scheduler"
```



약 10분 내외로 삭제된 컨테이너가 재실행 됨

```sh
root@node2:/etc/kubernetes# kubectl get nodes
NAME    STATUS   ROLES    AGE    VERSION
node1   Ready    master   4h5m   v1.17.12
node2   Ready    master   4h5m   v1.17.12
node3   Ready    <none>   4h3m   v1.17.12
node4   Ready    <none>   4h3m   v1.17.12
node5   Ready    <none>   4h3m   v1.17.12
```

