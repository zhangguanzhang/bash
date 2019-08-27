```
[root@k8s-m1 txt]# cat txt
DRAMC_DQIDLY4[21c]=0C090C0A
DRAMC_PADCTL4[0e4]=000022B3
00e048c2b7a1
DRAMC_DQIDLY1[210]=0F0E0C0F
DRAMC_DQIDLY2[214]=090D0B0D
DRAMC_DQIDLY3[218]=0E0A0909
DRAMC_DQIDLY4[21c]=0C090C0A
DRAMC_DDR2CTL[07c]=C287222D
DRAMC_PADCTL4[0e4]=000022B3
00ea1b2b12b
DRAMC_DQIDLY1[210]=0F0E0C0F
DRAMC_DQIDLY2[214]=090D0B0D
DRAMC_DQIDLY3[218]=0E0A0909
DRAMC_DQIDLY4[21c]=0C090C0A
```
假如关键字为`DRAMC_DQIDLY4[21c]=0C090C0A`把关键字里非[]的行当作文件名，其余内容当作内容写到文件里
```
[root@k8s-m1 txt]# str='DRAMC_DQIDLY4[21c]=0C090C0A'
[root@k8s-m1 txt]# flag=0
[root@k8s-m1 txt]# while read line;do
>      grep -Pq '\[' <<<"$line" ||  { filename=$line;continue; }
>      if [ "$line" == "$str" ];then
>          flag=$[flag + 1]
>          [ "$flag" -ge 2 ] && { flag=1; mv tmpfile $filename; }
>      else
>          echo $line >> tmpfile
>      fi
> done < txt
[root@k8s-m1 txt]# ll
total 336
-rw-r--r-- 1 root root    112 Aug 27 23:20 00e048c2b7a1
-rw-r--r-- 1 root root    140 Aug 27 23:20 00ea1b2b12b
-rw-r--r-- 1 root root    361 Aug 27 23:01 txt
[root@k8s-m1 txt]# cat 00e048c2b7a1 
DRAMC_PADCTL4[0e4]=000022B3
DRAMC_DQIDLY1[210]=0F0E0C0F
DRAMC_DQIDLY2[214]=090D0B0D
DRAMC_DQIDLY3[218]=0E0A0909
[root@k8s-m1 txt]# cat 00ea1b2b12b 
DRAMC_DDR2CTL[07c]=C287222D
DRAMC_PADCTL4[0e4]=000022B3
DRAMC_DQIDLY1[210]=0F0E0C0F
DRAMC_DQIDLY2[214]=090D0B0D
DRAMC_DQIDLY3[218]=0E0A0909
```
