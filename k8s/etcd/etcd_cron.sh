#!/bin/bash
set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

:  ${bak_dir:=/root/} #缺省备份目录,可以修改成存在的目录

bak_prefix='etcd-'
cmd_suffix='date +%Y-%m-%d-%H:%M'
bak_suffix='.db'

#将规范化后的命令行参数分配至位置参数（$1,$2,...)
temp=`getopt -n $0 -o c:d: -u -- "$@"`

[ $? != 0 ] && {
    echo '
Examples:
  # just save once
  bash $0 /tmp/etcd.db
  # save in contab and  keep 5
  bash $0 -c 5
    '
    exit 1
    }
set -- $temp


# -c 备份保留副本数量
# -d 指定备份存放目录
while true;do
    case "$1" in
        -c)
            [ -z "$bak_count" ] && bak_count=$2
            printf -v null %d "$bak_count" &>/dev/null || \
                { echo 'the value of the -c must be number';exit 1; }
            shift 2
            ;;
        -d)
            [ ! -d "$2" ] && mkdir -p $2
            bak_dir=$2
            shift 2
            ;;
         *)
            [[ -z "$1" || "$1" == '--' ]] && { shift;break; }
            echo "Internal error!"
            exit 1
            ;;
    esac
done


function etcd_v2(){

    etcdctl --cert-file /etc/kubernetes/pki/etcd/healthcheck-client.crt --key-file \
        /etc/kubernetes/pki/etcd/healthcheck-client.key \
        --ca-file /etc/kubernetes/pki/etcd/ca.crt \
        --endpoints https://100.64.2.62:2379,https://100.64.2.63:2379,https://100.64.2.64:2379 $@
}

function etcd_v3(){

    ETCDCTL_API=3 etcdctl   \
       --cert /etc/kubernetes/pki/etcd/healthcheck-client.crt \
       --key /etc/kubernetes/pki/etcd/healthcheck-client.key \
       --cacert /etc/kubernetes/pki/etcd/ca.crt \
       --endpoints https://100.64.2.62:2379,https://100.64.2.63:2379,https://100.64.2.64:2379 $@
}

etcd::cron::save(){
    cd $bak_dir/
    etcd_v3 snapshot save  $bak_prefix$($cmd_suffix)$bak_suffix
    rm_files=`ls -t $bak_prefix*$bak_suffix | tail -n +$[bak_count+1]`
    if [ -n "$rm_files" ];then
        rm -f $rm_files
    fi
}

main(){
    [ -n "$bak_count" ] && etcd::cron::save || etcd_v3 snapshot save $@
}

main $@

#  -c 用与指定在crontab下的保留的副本数量，不用-c是只备份不会考虑老的备份删除
#  -d 指定备份目录
#  也可以复用，参照下面
# 0 2 * * * cert_dir=/etc/kubernetes/pki/etcd-b endpoints=https://100.64.2.62:2379,https://100.64.2.63:2379,https://100.64.2.64:2379   bash /root/zhangxxxxxx/Kubernetes-ansible/etcd.sh -c 4 -d /data/etcd_bak/b/
# 2 2 * * *  bash /root/zhangxxxxxx/Kubernetes-ansible/etcd.sh -c 4 -d /data/etcd_bak/a/
#
