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

# https://github.com/docker/hub-feedback/issues/2127
# delete images and/or tags
curl -X DELETE -s -LH "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${repo}/${img_name}/
curl -X DELETE -s -LH "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${repo}/${img_name}/tags/${tag}/


# get single tag some info
curl -sL 'https://cloud.docker.com/v2/repositories/zhangguanzhang/gcr.io.google_containers.busybox/tags/1.27.2'   | jq .
{
  "name": "1.27.2",
  "full_size": 715181,
  "images": [
    {
      "size": 715181,
      "architecture": "amd64",
      "variant": null,
      "features": null,
      "os": "linux",
      "os_version": null,
      "os_features": null
    }
  ],
  "id": 30843029,
  "repository": 5723348,
  "creator": 2365835,
  "last_updater": 2365835,
  "last_updated": "2018-07-15T08:45:33.196114Z",
  "image_id": null,
  "v2": true
}
