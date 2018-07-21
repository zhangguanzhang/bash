#------保持单引号----------
quote()
{
    local quoted=${1//\'/\'\\\'\'}
    printf "'%s'" "$quoted"
}

[root@k8s-n1 ~]# a="'/test1/test2''"
[root@k8s-n1 ~]# echo $a
'/test1/test2''
[root@k8s-n1 ~]# quote $a
''\''/test1/test2'\'''\'''
#----------------------------
