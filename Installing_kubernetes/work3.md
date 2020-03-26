

#epel-release
cd /root
scp root@admin:/var/www/repo/epel-release-latest-7.noarch.rpm .
rpm -ivh epel-release-latest-7.noarch.rpm

#ansible
yum install -y ansible

#added
yum install -y python2-pip
yum install -y python36

#node1 srv
#ruamel.yaml
scp root@admin:/var/www/piprepo/ruamel* .
pip install ruamel.ordereddict-0.4.14-cp27-cp27mu-manylinux1_x86_64.whl ruamel.yaml-0.15.96-cp27-cp27mu-manylinux1_x86_64.whl

scp admin:/var/www/piprepo.tar .
tar xf piprepo.tar
cd piprepo
pip install netaddr-0.7.19-py2.py3-none-any.whl
#all servers
pip install Jinja2-2.10.1-py2.py3-none-any.whl  MarkupSafe-1.1.1-cp27-cp27mu-manylinux1_x86_64.whl

#git clone kubespray
scp root@admin:/var/www/kubespray_origin.tar .
tar xf kubespray_origin.tar

#kubespray
cd kubespray
cp -rfp inventory/sample inventory/mycluster

touch inventory/mycluster/hosts.yaml
declare -a IPS=(10.0.1.15 10.0.1.16 10.0.1.17 10.0.1.18 10.0.1.19)
CONFIG_FILE=inventory/mycluster/hosts.yml python contrib/inventory_builder/inventory.py ${IPS[@]}


#kubespray config
 vi inventory/mycluster/group_vars/all/docker.yml
```
## An obvious use case is allowing insecure-registry access to self hosted registries.
## Can be ipaddress and domain_name.
## example define 172.19.16.11 or mirror.registry.io
docker_insecure_registries:
#   - mirror.registry.io
  - admin:5000
```  

vi inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml 
```
# kubernetes image repo define
gcr_image_repo: "admin:5000"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
docker_image_repo: "admin:5000"

# quay image repo define
quay_image_repo: "admin:5000"
```


vi roles/container-engine/docker/defaults/main.yml
#CentOS/RedHat docker-ce repo
#docker_rh_repo_base_url: 'https://download.docker.com/linux/centos/7/$basearch/stable'
#docker_rh_repo_gpgkey: 'https://download.docker.com/linux/centos/gpg'
docker_rh_repo_base_url: 'http://admin/docker-ce/linux/centos/7/$basearch/stable'
docker_rh_repo_gpgkey: 'http://admin/docker-ce/linux/centos/gpg'

#CentOS/RedHat Extras repo
#extras_rh_repo_base_url: "http://mirror.centos.org/centos/$releasever/extras/$basearch/"
#extras_rh_repo_gpgkey: "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7"
extras_rh_repo_base_url: "http://admin/docker-mirror/centos/$releasever/extras/$basearch/"
extras_rh_repo_gpgkey: "http://admin/docker-mirror/centos/RPM-GPG-KEY-CentOS-7"



vi inventory/mycluster/group_vars/all/all.yml
apiserver_loadbalancer_domain_name: admin
loadbalancer_apiserver:
  address: admin
  port: 16443



* 주요 다운로드 URL을 내부망으로 변경
kubespray/roles/download/defaults/main.yml

# gcr and kubernetes image repo define
#gcr_image_repo: "gcr.io"
gcr_image_repo: "admin:5000"
kube_image_repo: "{{ gcr_image_repo }}/google-containers"

# docker image repo define
#docker_image_repo: "docker.io"
docker_image_repo: "admin:5000"

# quay image repo define
#quay_image_repo: "quay.io"
quay_image_repo: "admin:5000"

* system hostname
vi roles/bootstrap-os/defaults/main.yml
## General
# Set the hostname to inventory_hostname
#override_system_hostname: true
override_system_hostname: false





# Download URLs
#kubelet_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
#kubectl_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
#kubeadm_download_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
#etcd_download_url: "https://github.com/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
#cni_download_url: "https://github.com/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
#calicoctl_download_url: "https://github.com/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
#crictl_download_url: "https://github.com/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"

kubelet_download_url: "http://admin/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
kubectl_download_url: "http://admin/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
kubeadm_download_url: "http://admin/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
etcd_download_url: "http://admin/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
cni_download_url: "https://admin/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
calicoctl_download_url: "http://admin/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
crictl_download_url: "http://admin/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"


### kubespray install
ANSIBLE_VERBOSITY=4 
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml --flush-cache 
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml --flush-cache -vv
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml --flush-cache -vv --limit @/root/kubespray/cluster.retry 

ansible-playbook -i inventory/mycluster/hosts.yml reset.yml --flush-cache -y
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml --flush-cache -vv




## Error
TASK [etcd : Check_certs | Set 'sync_certs' to true] *************************************************************************************************************************************
task path: /root/kubespray/roles/etcd/tasks/check_certs.yml:57
fatal: [node1]: FAILED! => {"msg": "The conditional check 'gen_node_certs[inventory_hostname] or (not etcdcert_node.results[0].stat.exists|default(false)) or (not etcdcert_node.results[1].stat.exists|default(false)) or (etcdcert_node.results[1].stat.checksum|default('') != etcdcert_master.files|selectattr(\"path\", \"equalto\", etcdcert_node.results[1].stat.path)|map(attribute=\"checksum\")|first|default(''))' failed. The error was: no test named 'equalto'\n\nThe error appears to have been in '/root/kubespray/roles/etcd/tasks/check_certs.yml': line 57, column 3, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n- name: \"Check_certs | Set 'sync_certs' to true\"\n  ^ here\n"}

fatal: [node1]: FAILED! => {"msg": "The conditional check 'gen_node_certs[inventory_hostname] or (not etcdcert_node.results[0].stat.exists|default(false)) or (not etcdcert_node.results[1].stat.exists|default(false)) or (etcdcert_node.results[1].stat.checksum|default('') != etcdcert_master.files|selectattr(\"path\", \"equalto\", etcdcert_node.results[1].stat.path)|map(attribute=\"checksum\")|first|default(''))' failed. The error was: no test named 'equalto'\n\nThe error appears to have been in '/root/kubespray/roles/etcd/tasks/check_certs.yml': line 57, column 3, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n- name: \"Check_certs | Set 'sync_certs' to true\"\n  ^ here\n"}
==> pip install --upgrade python-jinja2
https://github.com/kubernetes-sigs/kubespray/issues/2967

TASK [etcd : Gen_certs | add CA to trusted CA dir] ***************************************************************************************************************************************
task path: /root/kubespray/roles/etcd/tasks/upd_ca_trust.yml:19
fatal: [node3]: FAILED! => {"changed": false, "msg": "Source /etc/ssl/etcd/ssl/ca.pem not found"}



TASK [network_plugin/calico : Calico | Configure calico network pool (version >= v3.3.0)] *******************************************************************************************************************
task path: /root/kubespray/roles/network_plugin/calico/tasks/install.yml:150
fatal: [node1]: FAILED! => {"changed": true, "cmd": "echo \"\n{ \"kind\": \"IPPool\",\n\"apiVersion\": \"projectcalico.org/v3\",\n\"metadata\": {\n\"name\": \"default-pool\",\n},\n\"spec\": {\n\"blockSize\": \"24\",\n\"cidr\": \"10.233.64.0/18\",\n\"ipipMode\": \"Always\",\n\"natOutgoing\": True }} \" | /usr/local/bin/calicoctl.sh apply -f -", "delta": "0:00:00.005030", "end": "2020-03-16 04:09:37.816021", "msg": "non-zero return code", "rc": 2, "start": "2020-03-16 04:09:37.810991", "stderr": "/usr/local/bin/calicoctl: line 1: syntax error near unexpected token `<'\n/usr/local/bin/calicoctl: line 1: `<html><body>You are being <a href=\"https://github-production-release-asset-2e65be.s3.amazonaws.com/29629333/36a5c700-233e-11ea-9d0c-d7e46abe6169?X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20200314%2Fus-east-1%2Fs3%2Faws4_request&amp;X-Amz-Date=20200314T054212Z&amp;X-Amz-Expires=300&amp;X-Amz-Signature=4e82e88452abac1fb55fee603d246d8861a28ee0c01b0976adc7748c6a7822f0&amp;X-Amz-SignedHeaders=host&amp;actor_id=0&amp;response-content-disposition=attachment%3B%20filename%3Dcalicoctl-linux-amd64&amp;response-content-type=application%2Foctet-stream\">redirected</a>.</body></html>'", "stderr_lines": ["/usr/local/bin/calicoctl: line 1: syntax error near unexpected token `<'", "/usr/local/bin/calicoctl: line 1: `<html><body>You are being <a href=\"https://github-production-release-asset-2e65be.s3.amazonaws.com/29629333/36a5c700-233e-11ea-9d0c-d7e46abe6169?X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20200314%2Fus-east-1%2Fs3%2Faws4_request&amp;X-Amz-Date=20200314T054212Z&amp;X-Amz-Expires=300&amp;X-Amz-Signature=4e82e88452abac1fb55fee603d246d8861a28ee0c01b0976adc7748c6a7822f0&amp;X-Amz-SignedHeaders=host&amp;actor_id=0&amp;response-content-disposition=attachment%3B%20filename%3Dcalicoctl-linux-amd64&amp;response-content-type=application%2Foctet-stream\">redirected</a>.</body></html>'"], "stdout": "", "stdout_lines": []}



    echo "
      { "kind": "IPPool",
        "apiVersion": "projectcalico.org/v3",
        "metadata": {
          "name": "default-pool",
        },
        "spec": {
          "blockSize": "24",
          "cidr": "10.233.64.0/18",
          "ipipMode": "Always",
          "natOutgoing": True }}" | /usr/local/bin/calicoctl.sh apply -f -











