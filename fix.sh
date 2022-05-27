#!/bin/bash
if [ -f /etc/redhat-release ]; then
    systemcommand="yum"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
    apt-get install tar
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    systemcommand="apt"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    systemcommand="yum"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
    apt-get install tar
elif cat /proc/version | grep -Eqi "ubuntu"; then
    systemcommand="apt"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    systemcommand="yum"
else
    echo -e "错误: 未检测到系统版本\n"
    exit 1
fi
if [ -f /etc/os-release ]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [ -z "$os_version" && -f /etc/lsb-release ]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [ x"${release}" == x"centos" ]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "错误: 请使用 CentOS 7 或更高版本的系统！\n"
        exit 1
    fi
elif [ x"${release}" == x"ubuntu" ]; then
    if [ ${os_version} -lt 16 ]; then
        echo -e "错误: 请使用 Ubuntu 16 或更高版本的系统！\n"
        exit 1
    fi
elif [ x"${release}" == x"debian" ]; then
    if [ ${os_version} -lt 8 ]; then
        echo -e "错误: 请使用 Debian 8 或更高版本的系统！\n"
        :exit 1
    fi
fi
  if [ `id -u` != 0 ];then
    echo -e "错误: 仅限 root 用户执行"
  fi  
  if [ $systemcommand == "yum" ]; then
    systemctl stop firewalld.service
    systemctl disable firewalld.service
    systemctl stop iptables
    systemctl disable iptables
    service stop iptables
    yum remove -y iptables
    yum remove -y firewalld
    yum install -y epel-release
    yum update -y
	yum install -y iproute
  elif  [ $systemcommand == "apt" ]; then
      iptables -F
    iptables -t nat -F
    iptables -P ACCEPT
    iptables -t nat -P ACCEPT
    service stop iptables
    apt-get remove -y iptables
    ufw disable
    apt-get install -y epel-release
    apt-get update -y
	apt-get install -y iproute2
  fi
  echo -e "完成"
