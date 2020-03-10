

haproxy 설치 : proxy1(10.128.15.213), proxy2(10.128.15.214)

web 설치 : web1(10.128.15.215), web2(10.128.15.216)



## WEB Server

web server 설치 : web1, web2

```
sudo apt install apache2 -y
```



web server 설정 수정

web1

```
sudo mv /var/www/html/index.html /var/www/html/index.html.backup

sudo vi /var/www/html/index.html
web1
```



web2

```
sudo mv /var/www/html/index.html /var/www/html/index.html.backup

sudo vi /var/www/html/index.html
web2
```





## HAProxy

대상서버 : proxy1, proxy2

### 1. Install HAProxy

```
sudo apt install haproxy -y
```



### 초기설정

```
$ sudo vi /etc/sysctl.conf

net.ipv4.ip_nonlocal_bind=1
net.ipv4.ip_forward=1

$ sudo sysctl -p
```



시스템 시작 시 자동 실행

```
echo "ENABLED=1" >> /etc/default/haproxy
```





### 2. Configure HAProxy Load Balancing

frontend, backend 설정 추가



* proxy1서버

```
sudo vi /etc/haproxy/haproxy.cfg

global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL). This list is from:
        #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
        # An alternative list with additional directives can be obtained from
        #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http
        
frontend Local_Server
    bind 10.128.15.213:80
    mode http
    default_backend My_Web_Servers

backend My_Web_Servers
    mode http
    balance roundrobin
    option forwardfor
    http-request set-header X-Forwarded-Port %[dst_port]
    http-request add-header X-Forwarded-Proto https if { ssl_fc }
    option httpchk HEAD / HTTP/1.1rnHost:localhost
    server web1.example.com  10.128.15.215:80
    server web2.example.com  10.128.15.216:80

frontend Local_Server
    bind *:16443
    mode tcp
    default_backend My_Web_Servers

backend My_Web_Servers
    mode tcp
    balance roundrobin
    server web1.example.com  10.128.15.199:6443
    server web2.example.com  10.128.15.200:6443
    server web3.example.com  10.128.15.201:6443

```



* proxy2 서버

```
sudo vi /etc/haproxy/haproxy.cfg

global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL). This list is from:
        #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
        # An alternative list with additional directives can be obtained from
        #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http
        
frontend Local_Server
    bind 10.128.15.214:80
    mode http
    default_backend My_Web_Servers

backend My_Web_Servers
    mode http
    balance roundrobin
    option forwardfor
    http-request set-header X-Forwarded-Port %[dst_port]
    http-request add-header X-Forwarded-Proto https if { ssl_fc }
    option httpchk HEAD / HTTP/1.1rnHost:localhost
    server web1.example.com  10.128.15.215:80
    server web2.example.com  10.128.15.216:80

```



### 3. Restart HAProxy

* verify configuration 

```
haproxy -c -f /etc/haproxy/haproxy.cfg
```



* restart HAProxy service

```
sudo service haproxy restart
```























## Keepalived

대상서버 : proxy1, proxy2

```
sudo apt install keepalived -y
```





```
vi /etc/keepalived/keepalived.conf

```



proxy1:

vi /etc/keepalived/keepalived.conf

```
global_defs {
        router_id HAproxy
}

# Define the script used to check if haproxy is still working
vrrp_script chk_haproxy {
        script "killall -0 haproxy"
        interval 2
        weight 2
}

# Configuration for the virtual interface
vrrp_instance VIS_1 {
        interface              enp0s3
        state                   MASTER
        priority                101
        virtual_router_id     51
        advert_int             1

        # The virtual ip address shared between the two loadbalancers
        virtual_ipaddress {
                10.128.15.213
        }

        # Use the script above to check if we should fail over
        track_script {
                chk_haproxy
        }
}

```



proxy2:

vi /etc/keepalived/keepalived.conf

```
global_defs {
        router_id HAproxyB
}

# Define the script used to check if haproxy is still working
vrrp_script chk_haproxy {
        script "killall -0 haproxy"
        interval 2
        weight 2
}

# Configuration for the virtual interface
vrrp_instance VIS_1 {
        interface              enp0s3
        state                   MASTER
        priority                100
        virtual_router_id     51
        advert_int             1

        # The virtual ip address shared between the two loadbalancers
        virtual_ipaddress {
                10.128.15.213
        }

        # Use the script above to check if we should fail over
        track_script {
                chk_haproxy
        }
}

```



```
sudo service keepalived restart
```









https://tecadmin.net/how-to-setup-haproxy-load-balancing-on-ubuntu-linuxmint/

https://livegs.tistory.com/44

https://5log.tistory.com/226

https://cloud.google.com/solutions/best-practices-floating-ip-addresses