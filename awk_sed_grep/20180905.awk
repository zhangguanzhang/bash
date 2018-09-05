我继续咨询一下：
AppType:19,AppID:9,AppNameLength:12,AppName:墨迹天气,AppUserNum:90,66,1620,180
AppType:22,AppID:133,AppNameLength:15,AppName:扫描全能王,AppUserNum:6,3,54,6
AppType:22,AppID:133,AppNameLength:15,AppName:扫描全能王,AppUserNum:84,42,756,84
AppType:22,AppID:133,AppNameLength:15,AppName:扫描全能王,AppUserNum:90,90,1620,180
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:6,35,114,6
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:82,478,1558,82
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:90,525,1710,90
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:92,537,1748,92

第一列，第二列相等，然后倒数第二列逐行相加，最后文本输出，还是 ：
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:270,1575,5130,270

这种样式，这个是怎么弄啊


[root@k8s-m1 ~]# cat txt
AppType:19,AppID:9,AppNameLength:12,AppName:墨迹天气,AppUserNum:90,66,1620,180
AppType:22,AppID:133,AppNameLength:15,AppName:扫描全能王,AppUserNum:6,3,54,6
AppType:22,AppID:133,AppNameLength:15,AppName:扫描全能王,AppUserNum:84,42,756,84
AppType:22,AppID:133,AppNameLength:15,AppName:扫描全能王,AppUserNum:90,90,1620,180
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:6,35,114,6
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:82,478,1558,82
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:90,525,1710,90
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:92,537,1748,92

[root@k8s-m1 ~]# awk -F':' -vOFS=":" '{end=$NF;$NF="";a[$0]=a[$0]?a[$0]" "end:end;}END{
> for(i in a){
>     len=split(a[i],f," ");
>     for(j=1;j<=len;j++){
>         flen=split(f[j],num,",")
> 
>         for(k=1;k<=flen;k++){
>             sum[k]+=num[k]
>         }
>     }
>     printf i
>     for(k=1;k<flen;k++)
>         printf sum[k]",";
>         printf sum[flen]"\n"
>         delete sum
> }
> }' txt
AppType:22,AppID:2,AppNameLength:16,AppName:WiFI万能钥匙,AppUserNum:270,1575,5130,270
AppType:19,AppID:9,AppNameLength:12,AppName:墨迹天气,AppUserNum:90,66,1620,180
AppType:22,AppID:133,AppNameLength:15,AppName:扫描全能王,AppUserNum:180,135,2430,270
