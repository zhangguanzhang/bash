[root@k8s-m1 txt_dir]# cat txt
userid   username
6000     aaaa
5000     bbbb
7000     cccc
[root@k8s-m1 txt_dir]# cat txt2
userid text time
6000     你叫什么      111111
5000      你是谁          22222
[root@k8s-m1 txt_dir]# awk 'NR==FNR{a[NR]=$1;$1="";b[NR]=$0}NR!=FNR{if(a[FNR]==$1){$1=$1" "b[FNR]};print}' txt txt2
userid  username text time
6000  aaaa 你叫什么   111111
5000  bbbb 你是谁 22222
####  中文粘贴乱码,随便粘贴下,需求是同行插入合并
