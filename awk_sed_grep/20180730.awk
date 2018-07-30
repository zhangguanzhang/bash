#对docker ps -a的名字进行排序
docker ps -a | awk 'NR==1{print $0};NR!=1{end=$NF;$NF="";a[end]=$0;}END{len=asorti(a,ta);for(i=1;i<=len;i++)print a[ta[i]],ta[i]}'

docker ps -a --format 'table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{"1"}}' | awk 'NR==1{print $0}NR!=1{print | "sort"}'| sed -r 's#(\S+\s+)(.+)1#\2\1#'
