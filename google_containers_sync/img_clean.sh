#!/bin/bash
REPOSITORY=gcr.io/google_containers
MY_REPO=zhangguanzhang
interval=.

Prefix=`sed 's#/#'"$interval"'#g'<<<${REPOSITORY%/}/`
repository_dir=${Prefix::-1}

while read img tag null;do
    docker push $img:$tag;docker rmi $img:$tag;
    [ "$tag" != latest ] && :>$repository_dir/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag || {
        gcloud container images list-tags --format='get(DIGEST)' \
            `sed "s#$MY_REPO/$Prefix#${REPOSITORY%/}/#"<<<$img` --filter="tags=latest" \
            > $repository_dir/`sed 's#'"$MY_REPO/$Prefix"'##'<<<$img`/$tag
    }
done < <(docker images --format {{.Repository}}' '{{.Tag}}' '{{.Size}} | awk -vcut=$MY_REPO/$Prefix '$0~cut{print $0 | "sort -hk3" }')
