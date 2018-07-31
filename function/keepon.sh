#中断后还从上次位置执行,用于长期循环一个列表做动作,#标记当前应该继续的位置
$ cat txt
1 #
2
3
4
#-----------------------


while read repo;do
    [[ "$repo" == *@ ]] && { sed -ri 's#\s+@##;1s@$@ #@;' txt;break; }
    [[ "$repo" == *# ]] || sed -i '/'"$repo"'/s@$@ #@' txt;
    echo $repo
    sleep 6
    sed -i '/'"$repo"'/d' txt;echo "${repo%% *}"' @' >> txt
done < txt
sed -ri 's#\s+@##;1s@$@ #@;' txt


#----------------------------------------------------
#上面方法太弱智了...
$ cat txt
1
2
3
4
array=(`xargs -n1 < txt`)
for i in ${array[@]};do
  sleep 6
  sed '/'"$i"'/d' txt;echo "$i" >> txt
done
