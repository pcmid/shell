#!/bin/bash
#路径
cd /usr/share/easy-rsa/2.0
if [ `pwd` != "/usr/share/easy-rsa/2.0" ]
then 
	echo "路径错误"
	exit
fi

#设置端口等
port_p=('53' 'udp')

read -a port_p -p "输入监听端口及类型 [53 udp]:"
if [ ${#port_p[@]} != 2 ]
then
	printf "输入错误\n"
	exit
fi

echo  "获取公网ip"
ip=`curl ip.cip.cc`

#配置用户
echo "开始配置用户，空输入退出"
while printf "输入用户名 :"&& read user
do
	if [ -z ${user} ]
	then
		echo "结束输入"
		break
	fi
    source vars 
	./build-key ${user}
	printf "client \ndev tun \nproto ${port_p[1]}\nremote ${ip} \nresolv-retry infinite \nnobind \npersist-key \npersist-tun \nns-cert-type server \ncomp-lzo \nverb 3 \ntls-auth [inline] 1 \nsndbuf 0 \nrcvbuf 0 \npush \"dhcp-option DNS 10.8.0.1\" \npush \"dhcp-option WINS 10.8.0.0\" \npush \"redirect-geteway def1\" \n<ca>\n" >${user}.ovpn
	cat keys/ca.crt >> ${user}.ovpn
	printf "</ca>\n<cert>\n" >> ${user}.ovpn
	cat keys/${user}.crt >> ${user}.ovpn
	printf "</cert>\n<key>\n" >> ${user}.ovpn
	cat keys/${user}.key >> ${user}.ovpn
	printf "</key>\n<tls-auth>\n" >> ${user}.ovpn
	cat keys/ta.key >> ${user}.ovpn
	printf "</tls-auth>" >> ${user}.ovpn

	#结尾
	mv ${user}.ovpn /root/
	echo "用户${user}配置完成"
done
exit
