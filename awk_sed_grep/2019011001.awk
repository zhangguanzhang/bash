[root@k8s-m1 ~]# seq 16 | awk  'NR%4!=0{a=a?a" "$0:$0}NR%4==0{print a"\n"$0;a="";}END{if(a)print a}'
1 2 3
4
5 6 7
8
9 10 11
12
13 14 15
16
[root@k8s-m1 ~]# seq 15 | awk  'NR%4!=0{a=a?a" "$0:$0}NR%4==0{print a"\n"$0;a="";}END{if(a)print a}'
1 2 3
4
5 6 7
8
9 10 11
12
13 14 15


# 三行空格合并,第四行不合并
