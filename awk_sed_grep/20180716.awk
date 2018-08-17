[root@k8s-n2 ~]# seq 9 | xargs -n3
1 2 3
4 5 6
7 8 9
[root@k8s-n2 ~]# seq 9 | xargs -n3 | awk '{a=b;b=$2}END{print a}'
5
