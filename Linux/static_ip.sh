#!/bin/bash
# ******************************************************
# 作用：根据主机目前IP地址更换为静态IP，或者手动输入IP地址用于跟换(手动更换要提供网卡名哦)。
# 时间：2021-3-22 
# ******************************************************

echo -e "   ================================\n
           请选择修改静态IP方法     \n
      1. 根据系统IP地址自动修改 \n
      2. 手动输入新的IP地址         \n
    ================================" 
read -p "请输入要操作的序列号:  " ID
if 
    [ $ID -eq 1  ] 
then
cp /etc/sysconfig/network-scripts/ifcfg-$(ip route show | awk '/default/ { print $5 }')  /etc/sysconfig/network-scripts/ifcfg-$(ip route show | awk '/default/ { print $5 }').bak 
echo "TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=$(ip route show | awk '/default/ { print $5 }')
UUID=$(uuidgen)
DEVICE=$(ip route show | awk '/default/ { print $5 }')
ONBOOT=yes
IPADDR=$(ifconfig $( ip route show | awk '/default/ { print $5 }' ) |sed -n 2p |awk -F ' ' '{print$2}')
NETMASK=$(ifconfig $( ip route show | awk '/default/ { print $5 }' ) |sed -n 2p |awk -F ' ' '{print$4}')
GATEWAY=$(ip route show | awk '/default/ { print $3 }')
" > /etc/sysconfig/network-scripts/ifcfg-$(ip route show | awk '/default/ { print $5 }')
systemctl restart network  && echo  "     =============== 已成功更换IP地址 ===============      
      *            IP 地址 ： ` ifconfig $(ip route show | awk '/default/ { print $5 }') |sed -n 2p |awk -F ' ' '{print$2}' `        *
      *            子网掩码： ` ifconfig $(ip route show | awk '/default/ { print $5 }') |sed -n 2p |awk -F ' ' '{print$4}' `          *
      *            网关地址： `    ip route show | awk '/default/ { print $3 }'`          *                                            
      ************************************************"
elif 
    [ $ID -eq 2  ] 
then

read -p "请输入网卡信息:  " ipdevice #请输入要修改的网卡名称
read -p "请输入IP地址:  " ipaddr  # 输入静态IP地址
read -p "请输入子网掩码:  " netmask # 输入子网掩码
read -p "请输入网关地址:  " gateway # 输入网关
read -p "请输入DNS:  " dns1 # 输入DNS地址
cp /etc/sysconfig/network-scripts/ifcfg-${ipdevice}  /etc/sysconfig/network-scripts/ifcfg-${ipdevice}.bak    # 网卡做备份
echo "TYPE=Etherne
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=${ipdevice}
UUID=$(uuidgen)
DEVICE=${ipdevice}
ONBOOT=yes
IPADDR=${ipaddr}
NETMASK=${netmask}
GATEWAY=${gateway}
DNS1=${dns1}
" > /etc/sysconfig/network-scripts/ifcfg-${ipdevice} 
systemctl restart network  && echo  "     =============== 已成功更换IP地址 ===============      
      *            IP 地址 ： ` ifconfig $(ip route show | awk '/default/ { print $5 }') |sed -n 2p |awk -F ' ' '{print$2}' `        *
      *            子网掩码： ` ifconfig $(ip route show | awk '/default/ { print $5 }') |sed -n 2p |awk -F ' ' '{print$4}' `          *
      *            网关地址： `    ip route show | awk '/default/ { print $3 }'`          *                                            
      ************************************************"
else
    echo "请输入正确的序号"
fi

