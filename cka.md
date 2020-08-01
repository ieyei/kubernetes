
[kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)  
[CKAD exercise](https://github.com/dgkanatsios/CKAD-exercises)


### 후기
https://blog.dudaji.com/kubernetes/2019/06/24/cka-acceptance-review-soonbee.html








## Logging & Monitoring





## Application Lifecycle Management

### Rolling Updates and Rollbacks

strategy

RollingUpdateStrategy

### Commands and Arguments

Dockerfile: ENTRYPOINT, CMD

pod : command, args



```
k run webapp-green --image=kodekloud/webapp-color --dry-run=client -o yaml -- --color=green > ans.yaml
```



### Env Variables

configmap

```
k create cm webapp-config-map --from-literal=APP_COLOR=darkblue
```

envFrom

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - configMapRef:
          name: special-config
  restartPolicy: Never
```



### Secrets

```
k create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123
```



envFrom

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - secretRef:
          name: mysecret
  restartPolicy: Never
```





### Multi Container PODs

create multiple containers

sidecar container



### Init Containers





## Cluster Maintenance

### OS Upgrade

drain

cordon

undordon

```
kubectl drain node01 --ignore-daemonsets

kubectl uncordon node01
```



```
kubectl drain node02 --ignore-daemonsets --force
```



```
kubectl cordon node03
```



### Cluster Upgrade Process

kubernetes cluster version



```
kubeadm upgrade plan
```



upgrade

master

```
kubectl drain master --ignore-daemonsets
```



```
apt install kubeadm=1.18.0-00
kubeadm upgrade apply v1.18.0
apt install kubelet=1.18.0-00
```

```
kubectl uncordon master
```

node01

```
kubectl drain node01 --ignore-daemonsets
```

```
apt install kubeadm=1.18.0-00 
kubeadm upgrade node
apt install kubelet=1.18.0-00
```

```
kubectl uncordon node01
```







### Backup and Restore Methods
