#########################################################################
# File Name: update-ipset.sh
# Author: pcmid
# Mail: plzcmid@gmail.com
# Created Time: 2018年06月13日 星期三 01时08分17秒
#########################################################################
#!/bin/bash

# check uid
if [ $UID -ne 0 ]
then
echo "Superuser privileges are required to run this script."
echo "e.g. \"sudo $0\""
exit 1
fi


#set urls map (with opetion)
declare -A url_map=(
    #中国电信 IP地址段：
    #["telecom"]="http://ispip.clang.cn/chinatelecom.html"
    #中国联通（网通）IP地址段：
    #["unicom"]="http://ispip.clang.cn/unicom_cnc.html"
    #中国移动 IP地址段
    #["cmcc"]="http://ispip.clang.cn/cmcc.html"
    #中国铁通 IP地址段：
    #["crtc"]="http://ispip.clang.cn/crtc.html"
    #中国教育网 IP地址段：
    #["cernet"]="http://ispip.clang.cn/cernet.html"
    #中国其他ISP IP地址段：
    #["othernet"]="http://ispip.clang.cn/othernet.html"
    
    #ispip
    ["ispip"]='-4skL https://ispip.clang.cn/all_cn_cidr.txt'
    ["ip2location"]="-d ipVersion=4&&countryCode[]=CN&&format=cidr&&btnDownload=Download -4skL https://www.ip2location.com/blockvisitorsbycountry.aspx"
)

#set global path
ipset_global_path="/etc/ipset.d"
# set ipset.conf path
ipset_path="/etc/ipset.conf"


#create empty file
echo "create empty file..."
echo "" > $ipset_path

#create empty set
chnip_set=()

# get ip list
for set_name in ${!url_map[@]}
do
    echo "get ${set_name}..."
    #add set to chnip set
    chnip_set=(${chnip_set} ${set_name})
    #create new hash
    echo "create ${set_name} hash:net family inet hashsize 2048 maxelem 65536" >> ${ipset_path}
    ip_list=$(curl ${url_map[${set_name}]} | egrep -v "^#.*$")
    for ip in ${ip_list}
    do
        echo "add ${set_name} ${ip}" >> ${ipset_path}
    done
done

# chnip set
echo "create chnip list:set size 8" >> ${ipset_path}
for set_name in ${chnip_set[@]}
do
    echo "add chnip ${set_name}" >> ${ipset_path}
done

#extra files
for file in ${ipset_global_path}/*.conf
do
test -r ${file} && cat ${file} >> ${ipset_path}
done
# Applying changes
echo "applying changes..."
systemctl stop iptables >/dev/null 2>&1
if [ $? -eq 0 ]
then
echo -e "\033[32msystemctl stop iptables\033[0m"
else
echo -e "\033[31msystemctl stop iptables\033[0m"
fi
ipset -F
ipset -X
systemctl reload ipset >/dev/null 2>&1
if [ $? -eq 0 ]
then
echo -e "\033[32msystemctl reload ipset\033[0m"
else
echo -e "\033[31msystemctl reload ipset\033[0m"
fi
systemctl start iptables >/dev/null 2>&1
if [ $? -eq 0 ]
then
echo -e "\033[32msystemctl start iptables\033[0m"
else
echo -e "\033[31msystemctl start iptables\033[0m"
fi


