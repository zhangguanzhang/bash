##生成一定范围内的随机数
##$1：最小的数
##$2：最大的数
function rand() {  
    local min=$1  
    local max=$(($2-min+1))  
    local num
    num=$(head -n 11 < /dev/urandom | cksum | awk -F ' ' '{print $1}') 
    echo $((num%max+min)) 
}


##生成随机号码
function create_random_phones () {
    echo "生成随机号码:${randSortedFile}......"

    local randFile=rand.txt
    local randSortedFile=num

    true > ${randFile}

    ##生成randFile(rand.txt)文件
    for (( i = 0; i < 6000; i = $((i + 1)) )); do
        rand 13400000000 13999999999 >>${randFile}
    done

    #排序随机号码
    sort -u ${randFile} > ${randSortedFile}

    #删除随机号码文件
    rm ${randFile}
} 
