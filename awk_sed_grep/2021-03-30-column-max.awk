```
$ cat 1
120.008 /sale/myCustomer/selectMyCreateOfCusromterInfo
14.199 /sale/sea/list
13.815 /sale/sea/list
3.416 /sysUser/queryShareUserList
3.320 /sale/myCustomer/selectMyCreateOfCusromterInfo
3.309 /sale/myCustomer/listManageCount
3.262 /sale/myCustomer/listManageCount
3.230 /sale/myCustomer/selectMyCreateOfCusromterInfo
3.085 /sale/myCustomer/selectMyCreateOfCusromterInfo
3.075 /sale/myCustomer/selectMyCreateOfCusromterInfo
3.047 /sale/myCustomer/selectMyCreateOfCusromterInfo
3.005 /sale/myCustomer/selectMyCreateOfCusromterInfo
2.937 /sale/myCustomer/selectMyCreateOfCusromterInfo
2.916 /sale/myCustomer/selectMyCreateOfCusromterInfo
2.865 /sale/myCustomer/selectMyCreateOfCusromterInfo
2.819 /sale/myCustomer/selectMyCreateOfCusromterInfo
2.811 /sale/myCustomer/selectMyCreateOfCusromterInfo
2.811 /sale/myCustomer/selectMyCreateOfCusromterInfo
2.767 /sale/sea/list
2.754 /sale/myCustomer/selectMyCreateOfCusromterInfo
$ awk '{if(a[$2]){if($1>a[$2])a[$2]=$1}else{a[$2]=$1}}END{for(i in a){print a[i],i}}' 1
14.199 /sale/sea/list
120.008 /sale/myCustomer/selectMyCreateOfCusromterInfo
3.416 /sysUser/queryShareUserList
3.309 /sale/myCustomer/listManageCount
```
