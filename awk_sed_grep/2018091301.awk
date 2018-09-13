[root@k8s-m1 txt_dir]# cat txt 
>12454p p2
aaaaaaaaaaabbbbb
>12455 p1
aaaaabbbbbbbbbbb
[root@k8s-m1 txt_dir]# cat txt2
>12454p p2
abaaaaaaaaabbbbb
>12455 p1
aacaabbbbbbbbbcb
[root@k8s-m1 txt_dir]# awk '{
  ($0 ~/^>/)?b=$0:(a[b]=a[b]?a[b]"\n"$0:$0)
}END{
  for(i in a){
    print i"\n"a[i]
  }
}' txt txt2
>12454p p2
aaaaaaaaaaabbbbb
abaaaaaaaaabbbbb
>12455 p1
aaaaabbbbbbbbbbb
aacaabbbbbbbbbcb
