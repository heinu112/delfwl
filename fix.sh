#!/bin/bash
if [ -f /etc/redhat-release ];then
    systemcommand="yum"
elif cat /etc/issue | grep -Eqi "debian"; then
    systemcommand="apt"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    systemcommand="apt"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    systemcommand="yum"
elif cat /proc/version | grep -Eqi "debian"; then
    systemcommand="apt"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    systemcommand="apt"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    systemcommand="yum"
else
    echo -e "错误: 未检测到系统版本\n" && exit 1
fi
if [ $systemcommand ];then
  if [ `id -u` != 0 ];then
    echo -e "错误: 仅限 root 用户执行"
  fi
  if [ $systemcommand == "yum" ];then
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    iptables-save
    iptables-persistent
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
  elif $systemcommand == "apt" ; then
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    iptables-save
    iptables-persistent
    apt-get install iptables-persistent
    netfilter-persistent save
    netfilter-persistent reload
    service stop iptables
    apt-get remove -y iptables
    ufw disable
    apt-get install -y epel-release
    apt-get update -y
	apt-get install -y iproute2
  fi
    echo -e "完成"
   else
    echo -e "错误: 未检测到系统版本\n"
    exit 1
    fi
