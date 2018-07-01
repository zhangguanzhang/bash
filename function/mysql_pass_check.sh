while :; do
    echo '请输入MySQL管理密码';
    read -p 'Please input the root password of database:' mysqlpwd
    [ -n "`grep '[+|&]'<<<"$mysqlpwd"`" ] && { echo "input error,not contain a plus sign (+) and & "; continue; }
    (( ${#mysqlpwd} >= 5 )) && break || echo 'database root password least 5 characters!'
done
