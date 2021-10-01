#!/usr/bin/env bash


dir_config=/ql/config
dir_script=/ql/scripts
bilibili_shell_path=$dir_config/bilibili.json
bili_shell_path=$dir_script/bili.sh
dir_y=1

# 控制是否执行变量
read -p "是否执行全部操作，输入 1 即可执行全部，输入 0 则跳出，回车默认和其他可进行选择性操作，建议初次配置输入 1：" all
if [ "${all}" = 1 ]; then
    echo "将执行全部操作"
elif [ "${all}" = 0 ]; then
    exit 0
else
    read -p "bilibili.json 操作（替换或下载选项为 y，不替换为 n，回车为替换）请输入：" Rconfig
    Rconfig=${Rconfig:-'y'}
    read -p "bili_update.sh 操作（替换或下载选项为 y，不替换为 n，回车为替换）请输入：" update
    update=${update:-'y'}
fi

# 检查域名连通性
check_url() {
    HTTP_CODE=$(curl -o /dev/null --connect-timeout 3 -s -w "%{http_code}" $1)
    if [ $HTTP_CODE -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# 获取有效 bilibili.json 链接
get_valid_bilibili() {
    bilibili_list=(https://ghproxy.com/https://raw.githubusercontent.com/Tiziyi/bilibili/main/bilibili.json https://raw.githubusercontent.com/Tiziyi/bilibili/main/bilibili.json https://raw.sevencdn.com/Tiziyi/bilibili/main/bilibili.jsonhttps://ghproxy.com/https://raw.githubusercontent.com/Tiziyi/bilibili/main/bilibili.json)
    for url in ${bilibili_list[@]}; do
        check_url $url
        if [ $? = 0 ]; then
            valid_url=$url
            echo "使用链接 $url"
            break
        fi
    done
}
# 下载 bilibili.json
dl_bilibili_shell() {
    if [ ! -a "$bilibili_shell_path" ]; then
        touch $bilibili_shell_path
    fi
    curl -sL --connect-timeout 3 $valid_url > $bilibili_shell_path
    cp $bilibili_shell_path $dir_config/bilibili.json
    # 判断是否下载成功
    bilibili_size=$(ls -l $bilibili_shell_path | awk '{print $5}')
    if (( $(echo "${bilibili_size} < 100" | bc -l) )); then
        echo "bilibili.json 下载失败"
        exit 0
    fi
}
if [ "${Rconfig}" = 'y' -o "${all}" = 1 ]; then
    get_valid_bilibili && dl_bilibili_shell
else



    echo "已为您跳过替换 bilibili.json"
fi

##下载jay包
cd /ql/scripts
latest=$(curl -s https://api.github.com/repos/JunzhouLiu/BILIBILI-HELPER-PRE/releases/latest)
latest_VERSION=`echo $latest | jq '.tag_name' | sed 's/v\|"//g'`
download_url=`echo $latest | jq '.assets[0].browser_download_url' | sed 's/"//g'`
echo "最新版本:"$latest_VERSION
echo"下载jay文件......"
curl -L -o "./BILIBILI-HELPER.zip" "https://ghproxy.com/$download_url"
mkdir ./blbl
echo "正在解压文件......."
unzip -d ./blbl/ BILIBILI-HELPER.zip
cp -f ./blbl/BILIBILI-HELPER*.jar /ql/scripts/BILIBILI-HELPER.jar
echo "清除缓存........."
rm -rf blbl
rm -rf BILIBILI-HELPER.zip
echo "下载完成"
##安装依赖
echo "安装依赖"
cd /ql && apk add openjdk8
sleep 5
echo "依赖安装完成"

# 将 bilibilijay包 添加到定时任务
echo "尝试添加定时任务"
add_bilibili_jay() {
if [ "$(grep -c "BILIBILI-HELPER" /ql/config/crontab.list)" != 0 ]; then
        echo "您的任务列表中已存在 java -jar /ql/scripts/BILIBILI-HELPER.jar"
    else
        echo "开始添加 java -jar /ql/scripts/BILIBILI-HELPER.jar"
        # 获取token
        token=$(cat /ql/config/auth.json | jq --raw-output .token)
        curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"运行海尔破","command":"java -jar /ql/scripts/BILIBILI-HELPER.jar /ql/config/bilibili.json","schedule":"51 0 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1624782068473'
    fi
}
# 运行一次 java -jar /ql/scripts/BILIBILI-HELPER.jar
run_bilibili_java() {
    java -jar /ql/scripts/BILIBILI-HELPER.jar /ql/config/bilibili.json
    sleep 5
}

if [ "${dir_r}" = 1 ]; then
    add_bilibili_jay && run_bilibili_java
else
    echo "已为您添加定时任务"
fi

# 提示配置结束
echo -e "\n配置到此结束，请前往/ql/config/bilibili.json填入配置"
