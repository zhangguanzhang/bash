#!/bin/bash
#记录一次爬取COCA的前两万个高频词汇
index='https://www.shanbay.com'
url='https://www.shanbay.com/wordbook/103867/'
book=`echo $url | awk -F'/' '{print $(NF-1)}'`
file_dir='word_list'
for unit in `curl -s $url | grep -Po "(?<=a href=\")/wordlist/${book}.+?/"`;do
    for page in `seq 5`;do
        curl -s ${index}${unit}?page=${page}|sed -rn '/<tr class="row">/,/<\/tr>/{/\/tr/d;/row/d;/span/s#^ +<.+>([^<]+)(<.+)?#\1#;s#</td>##;/^[a-zA-Z]+/s#^[a-zA-Z]+$#\n&#;p}'>>"$file_dir"
   done
done
