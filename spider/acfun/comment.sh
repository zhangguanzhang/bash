#!/bin/bash

cookies=cookies


curl -s -X POST -D $cookies https://id.app.acfun.cn/rest/web/login/signin -d username=1777xxxxxxxx -d password=xxxxxxxx -H @headers | jq .

err() {
  printf '%b\n' ""
  printf '%b\n' "\033[1;31m[ERROR] $@\033[0m"
  printf '%b\n' ""
  exit 1
} >&2


# id [pic_num] content
function comment(){
    local content pic_num
    [ -z "$1" ] && err 'function '${FUNCNAME[0]}' must use with id'
    [ $# -eq 2 ] && content=$2  # 第二个参数可选
    [ $# -eq 3 ] && { pic_num=$2;content=$3; }
    curl -s -X POST -b $cookies  http://www.acfun.cn/rest/pc-direct/comment/add \
        -d "sourceId=${1}&sourceType=1&replyToCommentId=0&content=[emot=ac,${pic_num:=13}/]${content:=前排第一。}" 
    sleep 7
}

# id
function get_comment(){
    local json id content
    id=$1
    [ -z "$id" ] && err 'function '${FUNCNAME[0]}' must use with id'
    json=`curl -sX GET http://www.acfun.cn/comment_list_json.aspx?contentId=$id | jq .data`
    [[ $(echo $json | jq '.commentList| length') -eq 0 ]] && comment $id
    echo $json | jq .commentContentArr[].userName | grep -Pq 张馆长 && return 0
    content=`echo $json | jq .commentContentArr[].content`
    echo $content | grep -Pq 恭喜 && { comment $id 25 恭喜，恭喜。;return 0; }
    echo $content | grep -Pq 好酸 && { comment $id 22 我好酸哦。;return 0; }
    echo $content | grep -Pq 分手 && { comment $id 25 关于感情问题我建议分手。;return 0; }
    comment $id `shuf -e {1..55} -n1` 我没悟我还顶得住。
}

function comment_first(){
    local ids
    ids=`curl -s -X POST -b $cookies 'http://www.acfun.cn/rest/pc-direct/feed/followFeed?isGroup=0&groupId=0&count=20&pcursor=1'    | jq '.feedList[].cid'`
    for id in $ids;do
        get_comment $id
    done
}

function article(){
    local ids
    ids=`curl -sX GET 'http://webapi.aixifan.com/query/article/list?pageNo=1&size=100&realmIds=25%2C34%2C7%2C6%2C17%2C1%2C2&originalOnly=false&orderType=2&periodType=-1&filterTitleImage=true' \
        | jq .data.articleList[].id`
    for id in $ids;do
        get_comment $id
        sleep 5
    done
}
