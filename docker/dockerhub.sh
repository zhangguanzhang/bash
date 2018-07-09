#!/bin/bash

#list all the images of my repostry
curl -s "https://hub.docker.com/v2/repositories/zhangguanzhang/?page_size=100" | jq -r '.results|.[]|.name'

# list the tag of the image
curl -s "https://hub.docker.com/v2/repositories/zhangguanzhang/kubedash/tags/?page_size=5" | jq -r '.results|.[]|.name'

