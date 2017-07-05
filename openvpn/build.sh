#!/bin/bash
#检查发行版
issue=`cat /etc/issue|head -1`

if [ "${issue%%' '*}x" != "CentOSx" ]
then 
	echo "暂不支持非CentOS"
	exit
fi

#安装环境
yum -y install openvpn easy-rsa

#生成证书
cd /usr/share/easy-rsa/2.0
if [ `pwd` != "/usr/share/easy-rsa/2.0" ]
then 
	echo "路径错误"
	exit
fi

source ./vars
./clean-all
./build-ca server
./build-key-server server
./build-dh
openvpn --genkey --secret ./keys/ta.key
#设置防火墙和路由转发

#设置端口
port_p=('53' 'udp')

printf 
read -a port_p -p "输入监听端口及类型 [53 udp]:"
if [ ${#port_p[@]} != 2 ]
then
	printf "输入错误\n"
	exit
fi

#检查版本
if [ ${issue:15:1} -le 6 ]
then
	iptables -I INPUT 1 -p ${port_p[1]} --dport ${port_p[0]} -j ACCEPT
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE -o eth0
	service iptables save
	service iptables restart
else
    printf "此脚本只支持CentOs6\n"
    exit
####CentOs7
#else
#	firewall-cmd --permanent --zone=public --add-port=${port[0]}/${port[1]}
#	firewall-cmd --permanent --zone=public --add-masquerade
#	firewall-cmd --permanent --zone=public --add-rich-rule='rule family=ipv4 source address=10.8.0.0/24 masquerade'
#	firewall-cmd --reload
fi

#检查sysctl.conf
sysctl="/etc/sysctl.conf"
if [ -s "$sysctl" ]
then	
	sed -i '/^net.ipv4.ip_forward/c\net.ipv4.ip_forward=1' ${sysctl}
else
	echo "net.ipv4.ip_forward=1" >${sysctl}
fi
sysctl -p 


#配置文件
ip=`curl ip.cip.cc`
printf "port ${port_p[0]} \nproto ${port_p[1]} \ndev tun \nca /usr/share/easy-rsa/2.0/keys/ca.crt \ncert /usr/share/easy-rsa/2.0/keys/server.crt \nkey /usr/share/easy-rsa/2.0/keys/server.key \ndh /usr/share/easy-rsa/2.0/keys/dh2048.pem \ntls-auth /usr/share/easy-rsa/2.0/keys/ta.key 0 \nserver 10.8.0.0 255.255.255.0 \nifconfig-pool-persist ipp.txt \nsndbuf 0 \nrcvbuf 0 \npush \"redirect-gateway def1 bypass-dhcp\" \npush \"dhcp-option DNS 8.8.8.8\" \nkeepalive 10 120 \ncomp-lzo \nuser nobody \ngroup nobody \npersist-key \npersist-tun \nstatus /var/log/openvpn-status.log \nlog /var/log/openvpn.log \nverb 3">/etc/openvpn/server.conf

#启动openvpn
service openvpn start

