#!/bin/bash
max_process=$1
MY_REPO=zhangguanzhang
interval=.
max_per=70
#--------------------------
GOOLE_NAMESPACE=(gcr.io/google_containers )
QUAY_NAMESPACE=(calico coreos prometheus)

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
        [ "$tag" != latest ] && :>$REPOSITORY/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag || {
            $@ `sed "s#$MY_REPO/$Prefix#${REPOSITORY%/}/#"<<<$img` > $REPOSITORY/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag
        }
    done < <(docker images --format {{.Repository}}' '{{.Tag}}' '{{.Size}} | awk -vcut=$MY_REPO/$Prefix '$0~cut{print $0 | "sort -hk3" }')
}
google_name(){
    gcloud container images list --repository=$@ --format="value(NAME)"
}
google_tag(){
    gcloud container images list-tags $@  --format="get(TAGS)" --filter='tags:*' | sed 's#;#\n#g'
}
google_latest_digest(){
    gcloud container images list-tags --format='get(DIGEST)' $@ --filter="tags=latest"
}
quay_name(){
    NS=${1#*/}
    curl -sL 'https://quay.io/api/v1/repository?public=true&namespace='${NS} | jq -r '"quay.io/'${NS}'/"'" + .repositories[].name"
}
quay_tag(){
    curl -sL "https://quay.io/api/v1/repository/${@#*/}?tag=info"  | jq -r .tags[].name
}
quay_latest_digest(){
#    curl -sL "https://quay.io/api/v1/repository/prometheus/alertmanager/tag" | jq -r '.tags[]|select(.name == "latest" and (.|length) == 5 ).manifest_digest'
    curl -sL "https://quay.io/api/v1/repository/${@#*/}/tag" | jq -r '.tags[]|select(.name == "latest" and (has("end_ts")|not) ).manifest_digest'
}
image_pull(){
    REPOSITORY=$1
    shift
    Prefix=`sed 's#/#'"$interval"'#g'<<<${REPOSITORY%/}/`
    # REPOSITORY is the name of the dir,convert the '/' to '.',and cut the last '.'
    [ ! -d "$REPOSITORY" ] && mkdir -p $REPOSITORY

    while read SYNC_IMAGE_NAME;do
        image_name=${SYNC_IMAGE_NAME##*/}
        MY_REPO_IMAGE_NAME=${Prefix}${image_name}
        [ ! -d "$REPOSITORY/$image_name" ] && mkdir -p "$REPOSITORY/$image_name"
        [ -f "$REPOSITORY/$image_name"/latest ] && mv $REPOSITORY/$image_name/latest{,.old}
        while read tag;do
        #处理latest标签
            [[ "$tag" == latest && -f "$REPOSITORY/$image_name"/latest.old ]] && {
                $@_latest_digest $SYNC_IMAGE_NAME > $REPOSITORY/$image_name/latest
                diff $REPOSITORY/$image_name/latest{,.old} &>/dev/null &&
                    { rm -f $REPOSITORY/$image_name/latest.old;continue; } ||
                    rm $REPOSITORY/$image_name/latest{,.old}
            }
            [ -f "$REPOSITORY/$image_name/$tag" ] && continue
            [ $(df -h| awk  '$NF=="/"{print +$5}') -ge "$max_per" ] && { wait;img_clean $@_latest_digest; }
            read -u5
            {
                [ -n "$tag" ] && image_tag $SYNC_IMAGE_NAME $tag $MY_REPO/$MY_REPO_IMAGE_NAME
                echo >&5
            }&
        done < <($@_tag $SYNC_IMAGE_NAME)
        wait
    done < <($@_name $REPOSITORY)
    img_clean $@_latest_digest
}


main(){

    Multi_process_init $max_process
    for repo in ${GOOLE_NAMESPACE[@]};do
        image_pull $repo google
    done
    for repo in ${QUAY_NAMESPACE[@]};do
        image_pull $repo quay
    done
    exec 5>&-;exec 5<&-
}

main
