#!/bin/bash
max_process=$1
REPOSITORY=gcr.io/google_containers
MY_REPO=zhangguanzhang
interval=.

Multi_process_init() {
    trap 'exec 5>&-;exec 5<&-;exit 0' 2
    pipe=`mktemp -u tmp.XXXX`
    mkfifo $pipe
    exec 5<>$pipe
    rm -f $pipe
    seq $1 >&5
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

        REPO_TAG_LIST=($(curl -s https://hub.docker.com/v2/repositories/${MY_REPO}/$MY_REPO_IMAGE_NAME/tags/?page_size=1000 | jq -r '.results[].name' 2>&1))
        [[ "${REPO_TAG_LIST[@]}" =~ error ]] && continue
        for tag in ${REPO_TAG_LIST[@]};do
            [ -f "$repository_dir/$image_name/$tag" ] && continue
            [ "$tag" == latest ] && { gcloud container images list-tags --format='get(DIGEST)' $GCR_IMAGE_NAME --filter="tags=latest" > $repository_dir/$image_name/latest;continue; }
            read -u5
            {
                [ -n "$tag" ] && :> $repository_dir/$image_name/$tag
                echo >&5
            }&
        done
        wait
    done < <(gcloud container images list --repository=$REPOSITORY --format="value(NAME)")
}


main(){
    Multi_process_init $max_process
    image_pull
    exec 5>&-;exec 5<&-
}

main
