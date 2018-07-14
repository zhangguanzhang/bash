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

