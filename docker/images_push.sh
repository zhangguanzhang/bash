MY_REPO=zhangguanzhang

#如果自己用去掉外层死循环,我是另一个脚本拉取谷歌镜像打成自己仓库的tag后利用这个脚本去推
while :;do
    while read img tag;do
        info=`sudo curl -s "https://hub.docker.com/v2/repositories/$MY_REPO/${img#*/}/tags/$tag/?page_size=1" | jq -r '.name' 2>&1`
        # if the info is null ,the images should be uploaded
        [ "$tag" == latest ] && { docker push $img:$tag;docker rmi $img:$tag;continue; }
        [[ "$info" =~ null|error ]] && { docker push $img:$tag;docker rmi $img:$tag; } || docker rmi $img:$tag

    done < <(docker images --format {{.Repository}}' '{{.Tag}} | grep -P "^$MY_REPO")
done
