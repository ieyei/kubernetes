# Repo 구성

## yum repo

all server



add host to servers

```
echo "10.0.1.14 admin" >> /etc/hosts
```



```
cd /etc/yum.repos.d/
mv rh-cloud.repo rh-cloud.repo.bk

vi custom.repo
[Custum-Repo]
name=custom repo
baseurl=http://admin/repo/
enabled=1
gpgcheck=0

yum update
```



```
yum install yum-utils -y
```





## Docker repo