package main

import (
	"encoding/json"
	"fmt"
	"github.com/go-resty/resty/v2"
	flag "github.com/spf13/pflag"
	"log"
	"os"
	"strings"
	"time"
)

type userPlayLists struct {
	Items []struct {
		ContentDetails struct {
			RelatedPlaylists struct {
				Uploads string `json:"uploads"`
			} `json:"relatedPlaylists"`
		} `json:"contentDetails"`
	} `json:"items"`
}

type response struct {
	NextPageToken string `json:"nextPageToken"`
	PrevPageToken string `json:"prevPageToken"`
	PageInfo      struct {
		TotalResults   int `json:"totalResults"`
		ResultsPerPage int `json:"resultsPerPage"`
	} `json:"pageInfo"`
	Items []struct {
		Snippet struct {
			Title        string `json:"title"`
			Description  string `json:"description"`
			ChannelTitle string `json:"channelTitle"`
		} `json:"snippet"`
		ContentDetails struct {
			VideoID          string    `json:"videoId"`
			VideoPublishedAt time.Time `json:"videoPublishedAt"`
		} `json:"contentDetails"`
	} `json:"items"`
}
//https://developers.google.com/youtube/v3/docs/playlistItems/list

const (
	domain  = "https://www.googleapis.com/youtube/v3"
	channelURL = domain + "/channels"
	playlistItemsURL = domain + "/playlistItems"
)

func main() {
	var (
		username, appKey, filename string
	)
	flag.StringVarP(&username, "username", "u", "8BitUniverseMusic", "which get from")
	flag.StringVarP(&appKey, "key", "k", "", "appKey")
	flag.StringVarP(&filename, "file", "f", "", "file name to write to")
	flag.Parse()

	client := resty.New()
	resp, err := client.R().SetQueryParams(
		map[string]string{
			"part": "contentDetails",
			"forUsername": username,
			"key": appKey,
	}).SetHeaders(map[string]string{
		"Accept":          "*/*",
		"Accept-encoding": "gzip, deflate, br",
		"Accept-language": "zh-CN,zh;q=0.9",
		"User-Agent":      "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36",
	}).Get(channelURL)

	handleError(err, "")
	var userData userPlayLists

	err = json.Unmarshal(resp.Body(), &userData)
	handleError(err, "")
	if ! resp.IsSuccess() {
		handleError(fmt.Errorf(string(resp.Body())), "")
	}
	var fd *os.File

	if filename != "" {
		fd, err = os.Create(filename)
		handleError(err, "")
	} else {
		fd = os.Stdout
	}
	for _, listID := range userData.Items {
		playlistId := listID.ContentDetails.RelatedPlaylists.Uploads
		fmt.Printf("Videos in list %s\r\n", playlistId)
		nextPageToken := ""
		for {
			time.Sleep(time.Second)
			// Retrieve next set of items in the playlist.
			resp, err := client.R().SetQueryParams(
				map[string]string{
					"part": "snippet,contentDetails",
					"playlistId": playlistId,
					"key": appKey,
					"maxResults": "50",
					"pageToken": nextPageToken,
				}).SetHeaders(map[string]string{
				"Accept":          "*/*",
				"Accept-encoding": "gzip, deflate, br",
				"Accept-language": "zh-CN,zh;q=0.9",
				"User-Agent":      "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36",
			}).Get(playlistItemsURL)
			handleError(err, "")
			var playlistResponse response
			err = json.Unmarshal(resp.Body(), &playlistResponse)
			handleError(err, "")

			for _, playlistItem := range playlistResponse.Items {
				title := strings.ReplaceAll(playlistItem.Snippet.Title, `"`,`\"`)
				videoId := playlistItem.ContentDetails.VideoID
				title = strings.ReplaceAll(title, `$`,`\$`)
				fmt.Fprintf(fd, `https://www.youtube.com/watch?v=%v '%v'` + "\n", videoId, title)
			}

			nextPageToken = playlistResponse.NextPageToken
			if nextPageToken == "" {
				break
			}
		}
	}
}

func handleError(err error, message string) {
	if message == "" {
		message = "Error making API call"
	}
	if err != nil {
		log.Fatalf(message + ": %v", err.Error())
	}
}
