#中断后还从上次位置执行,用于长期循环一个列表做动作
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
