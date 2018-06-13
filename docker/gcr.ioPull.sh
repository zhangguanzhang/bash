#!/bin/bash
set -e

[ -z "$1" ] && Mirror=mirrorgooglecontainers || Mirror=$1
#gcr.mirrors.ustc.edu.cn

[ -z "$img" ] && { echo '$img is not set';exit 2; }

[[ "$img" =~ ^gcr.io/google_containers ]] && {
    docker pull $Mirror"${img:24}"
    docker tag $Mirror"${img:24}" "$img"
    docker rmi $Mirror"${img:24}"
}

[[ "$img" =~ ^k8s.gcr.io ]] && {
    docker pull $Mirror"${img:10}"
    docker tag $Mirror"${img:10}" "$img"
    docker rmi $Mirror"${img:10}"
}
