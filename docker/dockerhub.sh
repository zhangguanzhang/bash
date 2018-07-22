#!/bin/bash

# Example for the Docker Hub V2 API
# Requires 'jq': https://stedolan.github.io/jq/

UNAME="zhangguanzhang"
UPASS=""
repo=zhangguanzhang
img_name=''
tag=''

# aquire token
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

# list all the images of my repo  (!!!!!I think this is not correct,it can't list all the images!!!!!!!)
curl -s https://hub.docker.com/v2/repositories/${repo}/?page_size=100 | jq -r .results[].name

# get all the tags of the image
curl -s https://hub.docker.com/v2/repositories/${repo}/${img_name}/tags/?page_size=1000 | jq -r '.results[].name'

# delete images and/or tags
curl -X DELETE -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${repo}/${img_name}/
curl -X DELETE -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${repo}/${img_name}/tags/${tag}/
