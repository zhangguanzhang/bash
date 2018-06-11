#!/bin/bash

set -e

[ "$(id -u)" != "0" ] && { echo -e '\e[32;1m Please run the script as root!!! \e[0m'; exit 1; }

mysql_conf=/etc/my.cnf
httpd_conf=/etc/httpd/conf/httpd.conf
http_port=9999
mysql_port=8888
mysqlpasswd=zhangguanzhang
webpath=/var/www

# while :; do
# 	echo '请输入MySQL管理密码';
# 	read -p 'Please input the root password of database:' mysqlpasswd
#     [ -n "`grep '[+|&]'<<<"$mysqlpasswd"`" ] && { echo "input error,not contain a plus sign (+) and & "; continue; }
# 	(( ${#mysqlpasswd} >= 5 )) && break || echo 'database root password least 5 characters!'
# done

# while :; do
# 	echo '请输入web目录的绝对路径';
# 	read -p 'Please input the web path of the nginx(default use nginx/html):' webpath
# 	[ -z "$webpath" ] && break
#     [ "${webpath:0:1}" != '/' ] \
#     	&& { echo "input error,not the right path"; continue; } \
#     	|| { [ ! -f "$webpath" ] && mkdir -p $webpath;break; }
# done

#------关闭selinux
sed -ri.`date +%s` '/^SELINUX=/s#=.*$#=disable#' /etc/selinux/config
#不关闭selinux的话使用apache自定义端口自行取消下面俩行注释后注释上面的sed行,mysql部分同理
#http_port_t=(80 81 443 488 8008 8009 8443 9000)
#[ -z "$(grep -w $http_port<<<${http_port_t[@]})" ] && semanage port -a -t http_port_t -p tcp $http_port
#
#不关闭selinux的话使用mysql自定义端口自行取消下面四行注释
#mysqld_port_t=(1186 3306 63132 63164)
#[ -z "$(grep -w $mysql_port<<<${mysqld_port_t[@]})" ] \
#	&& [ "$mysql_port" -gt 63132 -a "$mysql_port" -gt 63164] \
#	&& semanage port -a -t mysqld_port_t -p tcp $http_port


#------hostname-----
[ -z "$1" ] && { hostnamectl set-hostname $1;sed -ri '/127\.0\.0\.1/s#localhost\.localdomain#'$1'#' /etc/hosts; }

#-------apache-----
yum install -y httpd
sed -ri.`date +%s` '/^Listen/s#[0-9]+#'"$http_port"# $httpd_conf
sed -ri.`date +%s` '/^DocumentRoot/s#"(.+)"#"$webpath"#' $httpd_conf
firewall-cmd --permanent --zone=public --add-service=http{,s}
firewall-cmd --reload
systemctl start httpd
#------mysql------
#判断用户和组存不存在，不存在则创建
[ -z "$(grep '^mysql' /etc/group)" ] && { groupadd mysql; }
[ -z "$(grep '^mysql' /etc/passwd)" ] && { useradd -r -g mysql -s /bin/false -M mysql; }

#repo.rpm https://dev.mysql.com/downloads/repo/yum/
rpm -ivh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm 
#安装mysql客户端+mysql-community-client
yum install -y mysql-community-server


[ -z "$(grep -P 'port *=' $mysql_conf )" ] && \
	sed -ri.`date +%s` '/\[mysqld\]/a port = '$mysql_port $mysql_conf \
	|| sed -ri.`date +%s` '/port *=/s#=.+$#= '$mysql_port'#' $mysql_conf

#修改密码为用户设置的密码并删除数据库的匿名用户
[ -n "$mysqlpasswd" ] && mysqladmin -u root password "${mysqlpasswd}"
sed -i '$a [client]\npassword = '"$mysqlpasswd" $mysql_conf

systemctl start mysqld

#删除空用户名
mysql -uroot<<EOF
delete from mysql.user where user='';
flush privileges;
exit
EOF
sed -i '/password/d;/client/d' $mysql_conf

#----------php-----
yum -y install php{,-mysql}
cat>$webpath/phpinfo.php<<'EOF'
<?php
echo phpinfo();
EOF
systemctl restart httpd
