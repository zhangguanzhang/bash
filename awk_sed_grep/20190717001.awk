假设字符串为5，包含5的行和这行的上一行不打印
 
 $ seq 20 | awk '{
>     if($0!~"5"){
>         if(temp){
>             print temp;
>             temp=$0;
>         }else{
>             temp=$0;
>         }
>     }else{
>         temp="";
>         next;
>     }
> }END{print temp}'
1
2
3
6
7
8
9
10
11
12
13
16
17
18
19
20
