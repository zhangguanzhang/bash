#!/bin/bash
max_process=$1
REPOSITORY=gcr.io/google_containers
MY_REPO=zhangguanzhang
interval=.
max_per=70

Multi_process_init() {
    trap 'exec 5>&-;exec 5<&-;exit 0' 2
    pipe=`mktemp -u tmp.XXXX`
    mkfifo $pipe
    exec 5<>$pipe
    rm -f $pipe

    seq $1 >&5
}

#  GCR_IMAGE_NAME  tag  REPO_IMAGE_NAME
image_tag(){
    docker pull $1:$2
    docker tag $1:$2 $3:$2
    docker rmi $1:$2
#    docker push $4/$3:$2
}

img_clean(){
    while read img tag null;do
        docker push $img:$tag;docker rmi $img:$tag;
        [ "$tag" != latest ] && :>$repository_dir/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag || {
            gcloud container images list-tags --format='get(DIGEST)' \
                `sed "s#$MY_REPO/$Prefix#${REPOSITORY%/}/#"<<<$img` --filter="tags=latest" \
                > $repository_dir/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag
        }
    done < <(docker images --format {{.Repository}}' '{{.Tag}}' '{{.Size}} | awk -vcut=$MY_REPO/$Prefix '$0~cut{print $0 | "sort -hk3" }')
}

image_pull(){
    Prefix=`sed 's#/#'"$interval"'#g'<<<${REPOSITORY%/}/`
    # REPOSITORY is the name of the dir,convert the '/' to '.',and cut the last '.'
    repository_dir=${Prefix::-1}
    [ ! -d "$repository_dir" ] && mkdir $repository_dir

    while read GCR_IMAGE_NAME;do
        image_name=${GCR_IMAGE_NAME##*/}
        MY_REPO_IMAGE_NAME=${Prefix}${image_name}
        [ ! -d "$repository_dir/$image_name" ] && mkdir -p "$repository_dir/$image_name"
        [ -f "$repository_dir/$image_name"/latest ] && mv $repository_dir/$image_name/latest{,.old}
        while read tag;do
        #处理latest标签
            [[ "$tag" == latest && -f "$repository_dir/$image_name"/latest.old ]] && {
                gcloud container images list-tags --format='get(DIGEST)' $GCR_IMAGE_NAME --filter="tags=latest" > $repository_dir/$image_name/latest
                diff $repository_dir/$image_name/latest{,.old} &>/dev/null &&
                    { rm -f $repository_dir/$image_name/latest.old;continue; } ||
                    rm $repository_dir/$image_name/latest{,.old}
            }
            [ -f "$repository_dir/$image_name/$tag" ] && continue
            [ $(df -h| awk  '$NF=="/"{print +$5}') -ge "$max_per" ] && { wait;img_clean; }
            read -u5
            {
                [ -n "$tag" ] && image_tag $GCR_IMAGE_NAME $tag $MY_REPO/$MY_REPO_IMAGE_NAME
                echo >&5
            }&
        done < <(gcloud container images list-tags $GCR_IMAGE_NAME  --format="get(TAGS)" --filter='tags:*' | sed 's#;#\n#g')
        wait
    done < <(gcloud container images list --repository=$REPOSITORY --format="value(NAME)")
}


main(){
    Multi_process_init $max_process
    image_pull
    img_clean
    exec 5>&-;exec 5<&-
}

main
