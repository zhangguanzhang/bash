#获取api key https://blog.csdn.net/qq_27378621/article/details/80655208
# https://developers.google.com/youtube/v3/docs/playlistItems/list
#先从用户名获取用户id，然后用id去获取playlistItems
api_base=https://www.googleapis.com/youtube/v3
USERNAME=8BitUniverseMusic
KEY=""

_curl="curl -s"
ID=$( ${_curl} "${api_base}/channels?part=contentDetails&forUsername=${USERNAME}&key=${key}" | jq -r .items[].id )
nextPageToken=
while ;do
  ${_curl} "${api_base}/playlistItems?part=snippet,contentDetails&playlistId=${ID}&key=${key}&maxResults=50&pageToken=${nextPageToken}" > temp
  nextPageToken=$( jq .prevPageToken)
  [ "$nextPageToken" == null ] && break
  done
