所有的格式都是这样子的  以end结尾  正常应该是一行的
111 222 sad asdd asd end
但是文件里面全部都是乱的
111 222 sad asdsadasdd asd end
111 222as 
sad asdd asd
end
11123 22123 sad asdd asd end
asdasd asdsad asd
end
以end做分割全部  这一段里面的换行符去掉 还原成一行

[root@k8s-n1 temp]# cat file
111 222 sad asdsadasdd asd end
111 222as 
sad asdd asd
end
11123 22123 sad asdd asd end
asdasd asdsad asd
end
[root@k8s-n1 temp]# awk '{if($0!~"end")ORS=" ";else ORS="\n";print $0}' file
111 222 sad asdsadasdd asd end
111 222as  sad asdd asd end
11123 22123 sad asdd asd end
asdasd asdsad asd end
[root@k8s-n1 temp]# awk -vRS=end 'NF+=0{print $0,RS}' file
111 222 sad asdsadasdd asd end
111 222as sad asdd asd end
11123 22123 sad asdd asd end
asdasd asdsad asd end
