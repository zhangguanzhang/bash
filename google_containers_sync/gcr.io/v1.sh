#!/bin/bash
max_process=$1
MY_REPO=zhangguanzhang
interval=.
max_per=70
#--------------------------
GOOLE_NAMESPACE=(google_containers kubernetes-helm runconduit google-samples k8s-minikube tf-on-k8s-dogfood spinnaker-marketplace)
QUAY_NAMESPACE=(calico coreos prometheus outline weaveworks hellofresh kubernetes-ingress-controller replicated kubernetes-service-catalog 3scale wire)

Multi_process_init() {
    trap 'exec 5>&-;exec 5<&-;exit 0' 2
    pipe=`mktemp -u tmp.XXXX`
    mkfifo $pipe
    exec 5<>$pipe
    rm -f $pipe
    seq $1 >&5
}

git_init(){
    git config --global user.name "zhangguanzhang"
    git config --global user.email zhangguanzhang@qq.com
    git remote rm origin
    git remote add origin git@github.com:zhangguanzhang/gcr.io.git
    git pull
    if git branch -a |grep 'origin/develop' &> /dev/null ;then
        git checkout develop
        git pull origin develop
        git branch --set-upstream-to=origin/develop develop
    else
        git checkout -b develop
        git pull origin develop
    fi
}

git_commit(){
     local COMMIT_FILES_COUNT=$(git status -s|wc -l)
     local TODAY=$(date +%F)
     if [ $COMMIT_FILES_COUNT -ne 0 ];then
        git add -A
        git commit -m "Synchronizing completion at $TODAY"
        git push -u origin develop
     fi
}

add_yum_repo() {
cat > /etc/yum.repos.d/google-cloud-sdk.repo <<EOF
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
}

add_apt_source(){
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
}

install_sdk() {
    local OS_VERSION=$(grep -Po '(?<=^ID=")\w+' /etc/os-release)
    local OS_VERSION=${OS_VERSION:-ubuntu}
    if [[ $OS_VERSION =~ "centos" ]];then
        if ! [ -f /etc/yum.repos.d/google-cloud-sdk.repo ];then
            add_yum_repo
            yum -y install google-cloud-sdk
        else
            echo "gcloud is installed"
        fi
    elif [[ $OS_VERSION =~ "ubuntu" ]];then
        if ! [ -f /etc/apt/sources.list.d/google-cloud-sdk.list ];then
            add_apt_source
            sudo apt-get -y update && sudo apt-get -y install google-cloud-sdk
        else
             echo "gcloud is installed"
        fi
    fi
}

auth_sdk(){
    local AUTH_COUNT=$(gcloud auth list --format="get(account)"|wc -l)
    if [ $AUTH_COUNT -eq 0 ];then
        gcloud auth activate-service-account --key-file=$HOME/gcloud.config.json
    else
        echo "gcloud service account is exsits"
    fi
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
        [ "$tag" != latest ] && echo $REPOSITORY/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`:$tag > $REPOSITORY/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag || {
            $@ `sed "s#$MY_REPO/$Prefix#${REPOSITORY%/}/#"<<<$img` > $REPOSITORY/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag
        }
        [ $(time_check) -gt 45 ] && git_commit
    done < <(docker images --format {{.Repository}}' '{{.Tag}}' '{{.Size}} | awk -vcut=$MY_REPO/$Prefix '$0~cut{print $0 | "sort -hk3" }')
    git_commit
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
    curl -sL "https://quay.io/api/v1/repository/${@#*/}?tag=info" | jq -r '.tags[]|select(.name == "latest" and (has("end_ts")|not) ).manifest_digest'
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
            [ $(df -h| awk  '$NF=="/"{print +$5}') -ge "$max_per" -o $(time_check) -gt 40 ] && { wait;img_clean $@_latest_digest; }
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
time_check(){
    echo $(((`date +%s` - start_time)/60))
}
main(){
    readonly start_time=$(date +%s)
    git_init
    install_sdk
    auth_sdk
    Multi_process_init $max_process
    for repo in ${GOOLE_NAMESPACE[@]};do
        image_pull gcr.io/$repo google
    done
    for repo in ${QUAY_NAMESPACE[@]};do
        image_pull quay.io/$repo quay
    done
    exec 5>&-;exec 5<&-
}
main
