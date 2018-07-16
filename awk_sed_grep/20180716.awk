[root@k8s-n1 ~]# seq 10 | xargs -n2
1 2
3 4
5 6
7 8
9 10
[root@k8s-n1 ~]# seq 10 | xargs -n2 | awk '{for(i=1;i<=NF;i++){str1[i]=str2[i];str2[i]=$i}}END{print str1[2]}'
8
