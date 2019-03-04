[root@k8s-m1 blog]# cat txt
{name:vas/videozuul,tags::1.0.0,2.0.0}
{name:znxqproject/das-console,tags::1.0.1,1.0}
{name:znxqproject/das-engine,tags::1.0.1,1.0}
{name:znxqproject/data-dictionary,tags::1.0.1,1.0}
{name:znxqproject/dgs-admin,tags::1.0.1,1.0}
{name:znxqproject/face-dll-service,tags::2.0,1.0}
[root@k8s-m1 blog]# while read line;do
>  echo $line | awk -F'[:,}]'  '{for(i=5;i<NF;i++){print $2":"$i}}'
> done < txt
vas/videozuul:1.0.0
vas/videozuul:2.0.0
znxqproject/das-console:1.0.1
znxqproject/das-console:1.0
znxqproject/das-engine:1.0.1
znxqproject/das-engine:1.0
znxqproject/data-dictionary:1.0.1
znxqproject/data-dictionary:1.0
znxqproject/dgs-admin:1.0.1
znxqproject/dgs-admin:1.0
znxqproject/face-dll-service:2.0
znxqproject/face-dll-service:1.0
[root@k8s-m1 blog]# 
