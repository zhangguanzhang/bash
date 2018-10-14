# 软件前提
gcloud+梯子+jq,使用了travis构建,所以写好shell就行了,[点击跳转到对应仓库](https://github.com/zhangguanzhang/gcr.io)
利用gcloud去查询镜像名和tags
然后拉取后再改名推送
v1是每个tag利用docker registry的v2 api去查询,有就continue,没就拉取

镜像迭代是不会修改老镜像的,所以v1脚本繁琐,v2直接本地生成文件去判断同步了没

v2的latest标签处理思路

代码1:  有latest文件就改名为laetst.old
代码2:  是latest标签且有latest.old文件下获取最新的sha256到latest文件，对比latest{,.old},一样就删掉老的continue,不一样就新老一起删
代码3:  存在标签文件就跳过,不存在就拉取
推送代码：   推送的时候tag是latest就生成latest文件并写入sha256

第一次执行碰到latest标签:
代码1不会被执行没有old和latest文件，代码2不会被执行,代码3里会被拉取

第二次执行碰到这个latest标签：
代码1改名为old，代码2里获取最新sha256到latest，对比新老文件,一样就删掉老的跳过这个tag,不一样就新老一起删，一起删掉不存在标签文件触发3里的拉取
触发推送后生成latest标签文件

如果需要改代码的话,下面镜像可以拿去检测tag的分号和含有latest标签处理
含有latest标签

gcr.io/google_containers/addon-builder
gcr.io/google_containers/apparmor-loader
gcr.io/google_containers/busybox
gcr.io/google_containers/cadvisor
标签含有分号的镜像
gcr.io/google_containers/github-transform
gcr.io/google_containers/gke-mpi-api-server
gcr.io/google_containers/gke-mpi-metadata-server

参考文档

https://cloud.google.com/sdk/gcloud/reference/container/images/list
https://cloud.google.com/sdk/gcloud/reference/container/images/list-tags
