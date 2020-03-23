#!/bin/bash
set +e

user='az-user'
# docker && docker-compose
apt update -y
apt update && apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt update -y
apt install -y docker-ce
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker
chmod +x /usr/local/bin/docker-compose
usermod -aG docker $(user)
chmod 666 /var/run/docker.sock
# nginx 
cd /tmp/ && wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
sh -c "echo 'deb http://nginx.org/packages/mainline/ubuntu/ '$(lsb_release -cs)' nginx' > /etc/apt/sources.list.d/nginx.list"
apt update -y
apt install nginx
service nginx stop
#git clone https://github.com/fatedier/frp.git
apt-get install tinc
#
cd /home/${user}
#
wget -q https://cf-templates-18i7xm54rcn51-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/tmp/frp.tar
wget -q https://cf-templates-18i7xm54rcn51-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/tmp/trade2.tar
wget -q https://cf-templates-18i7xm54rcn51-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/tmp/nginx-conf.tar
wget -q https://cf-templates-18i7xm54rcn51-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/tmp/tinc-conf.tar
tar xf nginx-conf.tar -C /etc/nginx
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.org
tar xf tinc-conf.tar -C /etc/tinc
#wget -q https://cf-templates-18i7xm54rcn51-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/tmp/ingress.tar
tar xf frp.tar
tar xf trade2.tar
echo alias k=kubectl >> .bashrc
source .bashrc
chown -R ${user}:${user} /home/${user}
#
echo "VM for Network setup complete."

