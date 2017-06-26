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

printf "输入监听端口及类型 [53 udp]:"
read -a port_p

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
	./build-key ${user}
	printf "client \ndev tun \nproto ${port_p[1]}\nremote ${ip} \nresolv-retry infinite \nnobind \npersist-key \npersist-tun \nns-cert-type server \ncomp-lzo \nverb 3 \ntls-auth [inline] 1 \nsndbuf 0 \nrcvbuf 0 \npush \"dhcp-option DNS 10.8.0.1\" \npush \"dhcp-option WINS 10.8.0.0\" \npush \"redirect-geteway def1\" \n<ca>\n" >${user}.ovpn
	cat ca.crt >> ${user}.ovpn
	rm -rf ca.crt
	printf "</ca>\n<cert>\n" >> ${user}.ovpn
	cat ${user}.crt >> ${user}.ovpn
	rm -rf ${user}.crt
	printf "</cert>\n<key>\n" >> ${user}.ovpn
	cat ${user}.key >> ${user}.ovpn
	rm -rf ${user}.key
	printf "</key>\n<tls-auth>\n" >> ${user}.ovpn
	cat ta.key >> ${user}.ovpn
	rm -rf ta.key
	printf "</tls-auth>" >> ${user}.ovpn

	#结尾
	mv ${user}.ovpn /root/
	echo "用户${user}配置完成"
done
exit
