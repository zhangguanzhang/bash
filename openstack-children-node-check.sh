#!/bin/bash
set -e
password=WgsdfdsfU2mM5upm7hp
node1=10.200.0.37    #compute2,3
node2=10.200.0.38    #compute1,4

[ -f '/root/admin.sh' ] && source /root/admin.sh || exit 1
zones=`nova service-list | awk -F'[ |]+' '/zone.+down/{print $3}'`
[ -z "$zones" ] && exit 0

# $1 node[1-2] $2,$3 compute[1-4]
function get_remote_info(){
	remote_result=`sshpass -p $password ssh $1 'vim-cmd vmsvc/getall | awk '"'"'/Openstack-Compute[1-4]/{print $1,$2}'"'"`
	[ -n "$(egrep -i "$3.+$2"<<<$remote_result)" ] \
		&&  read $3 null $2 null< <(echo $remote_result) \
		||  read $2 null $3 null< <(echo $remote_result)
}

# $1 node[1-2] $2 compute[1-4]id
function restart_the_node(){
	sshpass -p $password ssh $1 'vim-cmd vmsvc/power.off '$2';vim-cmd vmsvc/power.on '$2
}

get_remote_info $node1 compute2 compute3
get_remote_info $node2 compute1 compute4

[[ "$zones" =~ compute1 ]] && restart_the_node $node2 $compute1
[[ "$zones" =~ compute4 ]] && restart_the_node $node2 $compute4
[[ "$zones" =~ compute2 ]] && restart_the_node $node1 $compute2
[[ "$zones" =~ compute3 ]] && restart_the_node $node1 $compute3
