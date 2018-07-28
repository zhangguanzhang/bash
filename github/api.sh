#list tha tree/develop path files
curl -sH 'ref:develop' https://api.github.com/repos/zhangguanzhang/gcr.io/contents/gcr.io/google_containers/busybox | jq -r .[].name
