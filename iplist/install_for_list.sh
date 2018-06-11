#!/bin/bash
#
#the path of th ip addr lists
IP_FIEL=/root/iplist
PASSWD=zhangguanzhang
PROCESS_MAX=10
url=www.zhangguanzhang.com/download/iplist/yum_install_amp.sh

count=`wc -l <$IP_FILE`

[ "$(id -u)" != "0" ] && { echo -e '\e[32;1m Please run the script as root!!! \e[0m'; exit 1; }
[ "$PROCESS_MAX" -gt "$count" ] && { echo -e '\e[32;1m the num of theprocess must small than the count!!! \e[0m'; exit 1; }

#check the software
[ ! -f '/usr/bin/sshpass' ] && yum install -y sshpass &>/dev/null

j=0;do_count=0;

for ip in `cat $IP_FILE`;do
	sshpass -p "$PASSWD" ssh $ip '[ ! -f "/usr/bin/wget" ] && yum install -y wget;wget '$url' -O install_amp.sh;bash install_amp.sh '"$ip" &
	((j++))
	((do_count++))
	[ "$do_count" -eq "$count" ] && { wait;break; }
	[ "$j" -eq "$PROCESS_MAX" ] && { wait;j=0; }
done
echo 'finished the job'
