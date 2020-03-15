

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


#git clone kubespray
scp root@admin:/var/www/kubespray_origin.tar .
tar xf kubespray_origin.tar

#kubespray
cd kubespray
cp -rfp inventory/sample inventory/mycluster

touch inventory/mycluster/hosts.yaml
declare -a IPS=(10.0.1.15 10.0.1.16 10.0.1.17 10.0.1.18 10.0.1.19)
CONFIG_FILE=inventory/mycluster/hosts.yaml python contrib/inventory_builder/inventory.py ${IPS[@]}

