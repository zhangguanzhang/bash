svn 权限配置文件修改authz，要求删除 : [gs-   开头的配置，求助！！！
修改前：
[g1-jssjb-sh:/]
szh=rw
lsb=rw
ysc=rw
luzx=rw
yhk=rw
meix=rw

[gs-11_yh:/]
chenl=rw
[gs-2B_/]
szh=rw
lsb=rw
ysc=rw

[gb-1231:/]
szh=rw
lsb=rw
ysc=rw
luzx=rw
yhk=rw
meix=rw
修改后：
[g1-jfs-sh:/]
szh=rw
lsb=rw
ysc=rw
luzx=rw
yhk=rw
meix=rw

[gb-s54ssx:/]
szh=rw
lsb=rw
ysc=rw
luzx=rw
yhk=rw
meix=rw
[root@guan temp]# awk -vRS="" '!/^\[gs-/' file
