## Kubernetes nfs이용하여 pv 자동 생성하기

local 환경에서 statefulset 사용을 위해 매번 pv 생성하는 일은 매우 번거로운 일이다. nfs 구성을 통해 pv 자동생성되도록 구성해 보자.

### NFS  Server 설치(ex master node)

```
apt-get update
apt-get install nfs-common nfs-kernel-server
```

nfs server 이외의 서버들(worker nodes)

```
apt-get update
apt-get install nfs-common
```

### 공유디렉토리 생성

```
mkdir ~/nfs_disk
chown nobody:nogroup ~/nfs_disk/
chmod 777 ~/nfs_disk
```
### 접근제어

```
$ sudo vi /etc/exports

#아래내용 추가
/home/gs/nfs_disk        192.168.56.0/24(rw,sync,no_subtree_check,no_root_squash)


# 이후 설정 반영
$ sudo exportfs -ra
$ sudo systemctl restart  
$ sudo systemctl restart nfs-kernel-server
```


**nfs-server-provisioner**를 이용하는 방법도 있음.

(https://github.com/helm/charts/tree/master/stable/nfs-server-provisioner)



## NFS Client

### nfs-client-provisioner

[nfs clinet chart](https://github.com/helm/charts/tree/master/stable/nfs-client-provisioner)

```
helm fetch stable/nfs-client-provisioner
tar -zxvf nfs-client-provisioner-1.2.8.tgz
cd nfs-client-provisioner

```

vi values.yaml

아래 내용만 수정

```
...
nfs:
  server: 192.168.56.111
  path: /home/gs/nfs_disk
...

  # Set StorageClass as the default StorageClass
  # Ignored if storageClass.create is false
  defaultClass: true

  # Set a StorageClass name
  # Ignored if storageClass.create is false
  name: nfs
 ...


```



nfs-client-provisioner 상위 디렉토리로 이동 후 helm install

```
$ cd ..
$ helm install nfs-client ./nfs-client-provisioner
NAME: nfs-client
LAST DEPLOYED: Wed Nov 20 11:48:45 2019
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ helm ls
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
nfs-client              default         1               2019-11-20 11:48:45.613030331 +0900 KST deployed        nfs-client-provisioner-1.2.8    3.1.0


$ kubectl get storageclass
NAME            PROVISIONER   AGE
nfs (default)   nfs-client    12m
```



### statefulset 배포하여 test

web.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 100Mi

```

```
kubectl apply -f web.yaml
```



### 확인

```
$ kubectl get pvc -l app=nginx
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
www-web-0   Bound    pvc-265b41d8-d51d-4b47-af9a-408f9686288e   100Mi      RWO            nfs            6m28s
www-web-1   Bound    pvc-470b9c1b-ddd5-4ffc-b460-6ae0db64311a   100Mi      RWO            nfs            5m50s

$ ls -l ~/nfs_disk/
total 8
drwxrwxrwx 2 root root 4096 Nov 20 12:16 default-www-web-0-pvc-265b41d8-d51d-4b47-af9a-408f9686288e
drwxrwxrwx 2 root root 4096 Nov 20 12:16 default-www-web-1-pvc-470b9c1b-ddd5-4ffc-b460-6ae0db64311a

```


