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

#  GCR_IMAGE_NAME  tag  IMAGE_NAME  MY_REPO
image_push(){
    docker pull $1:$2
    docker tag $1:$2 $4/$3:$2
    docker rmi $1:$2
#    docker push $4/$3:$2
}


img_clean(){
    while read img tag null;do
        info=`curl -s "https://hub.docker.com/v2/repositories/$MY_REPO/${img#*/}/tags/$tag/?page_size=1" | jq -r '.name' 2>&1`
        # if the info is null ,the images should be uploaded
        [ "$tag" == latest ] && { docker push $img:$tag;docker rmi $img:$tag;continue; }
        [[ "$info" =~ null|error ]] && { docker push $img:$tag;docker rmi $img:$tag; } || docker rmi $img:$tag
    done < <(docker images --format {{.Repository}}' '{{.Tag}}' '{{.Size}} | awk -vcut=$MY_REPO/$Prefix '$0~cut{print $0 | "sort -hk3" }')
}

image_pull(){
    sudo curl ipinfo.io &> /dev/null || bash /root/ssr/ssr-keep.sh
    # sudo gcloud container images list --repository=${REPOSITORY} --format="value(NAME)" | tr '/' '.' > all_image_name
    # sudo curl -s "https://hub.docker.com/v2/repositories/zhangguanzhang/?page_size=100" | jq -r '.results[].name'   > repo
    Prefix=`sed 's#/#'"$interval"'#g'<<<${REPOSITORY%/}/`

    while read GCR_IMAGE_NAME;do
        IMAGE_NAME=${Prefix}${GCR_IMAGE_NAME##*/}

        GCR_TAG_LIST=($(gcloud container images list-tags $GCR_IMAGE_NAME  --format="get(TAGS)" | sed 's@;@ @g' | xargs))
        
        REPO_TAG_LIST=($(curl -s https://hub.docker.com/v2/repositories/${MY_REPO}/$IMAGE_NAME/tags/?page_size=1000 | jq -r '.results[].name' 2>&1))
        # my repo don't has the image's all tag
        if [[ "${REPO_TAG_LIST[@]}" =~ error ]];then

            for tag in ${GCR_TAG_LIST[@]};do
                [ $(df -h| awk  '$NF=="/"{print +$5}') -ge 70 ] && { wait;img_clean; }
                read -u5
                {
                    [ -n "$tag" ] && image_push $GCR_IMAGE_NAME $tag $IMAGE_NAME $MY_REPO
                    echo >&5
                }&
            done
            wait
        else
            TAG_LIST=($(grep -vFf <(xargs -n1<<<${GCR_TAG_LIST[@]}) <(xargs -n1<<<${REPO_TAG_LIST[@]}) ))
            for tag in ${TAG_LIST[@]};do
                [ $(df -h| awk  '$NF=="/"{print +$5}') -ge "$max_per" ] && { wait;img_clean; }
                read -u5
                {
                    [ -n "$tag" ] && image_push $GCR_IMAGE_NAME $tag $IMAGE_NAME $MY_REPO
                    echo >&5
                }&
            done
            wait
        fi
        wait
    done < <(gcloud container images list --repository=${REPOSITORY} --format="value(NAME)")
}


main(){
    Multi_process_init $max_process
    image_pull
    img_clean
    exec 5>&-;exec 5<&-
}

main
