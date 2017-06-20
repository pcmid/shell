#!/bin/bash
if [ $# != 2 ]
then
	printf "参数错误\n"
	exit 1
fi
ip=$2
if [ $2 == server ]
then
	printf "port 53 \nproto udp \ndev tun \nca /usr/share/easy-rsa/2.0/keys/ca.crt \ncert /usr/share/easy-rsa/2.0/keys/server.crt \nkey /usr/share/easy-rsa/2.0/keys/server.key \ndh /usr/share/easy-rsa/2.0/keys/dh2048.pem \ntls-auth /usr/share/easy-rsa/2.0/keys/ta.key 0 \nserver 10.8.0.0 255.255.255.0 \nifconfig-pool-persist ipp.txt \nsndbuf 0 \nrcvbuf 0 \npush \"redirect-gateway def1 bypass-dhcp\" \npush \"dhcp-option DNS 8.8.8.8\" \nkeepalive 10 120 \ncomp-lzo \nuser nobody \ngroup nobody \npersist-key \npersist-tun \nstatus /var/log/openvpn-status.log \nlog /var/log/openvpn.log \nverb 3">/etc/openvpn/server.conf
	ip=`curl ip.cip.cc`
fi

printf "client \ndev tun \nproto udp\nremote ${ip} 53\nresolv-retry infinite \nnobind \npersist-key \npersist-tun \nns-cert-type server \ncomp-lzo \nverb 3 \ntls-auth [inline] 1 \nsndbuf 0 \nrcvbuf 0 \npush \"dhcp-option DNS 10.8.0.1\" \npush \"dhcp-option WINS 10.8.0.0\" \npush \"redirect-geteway def1\" \n<ca>\n" >$1.ovpn
cat ca.crt >> $1.ovpn
rm -rf ca.crt
printf "</ca>\n<cert>\n" >> $1.ovpn
cat $1.crt >> $1.ovpn
rm -rf $1.crt
printf "</cert>\n<key>\n" >> $1.ovpn
cat $1.key >> $1.ovpn
rm -rf $1.key
printf "</key>\n<tls-auth>\n" >> $1.ovpn
cat ta.key >> $1.ovpn
rm -rf ta.key
printf "</tls-auth>" >> $1.ovpn
