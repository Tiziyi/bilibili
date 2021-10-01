#!/usr/bin/env bash

##引用部分graytoowolf代码 更新文件来自graytoowolf
##代码虽然狗屎但是我测试还是能用的
##仓库地址https://github.com/JunzhouLiu/BILIBILI-HELPER-PRE

dir_config=/ql/config
dir_scripts=/ql/scripts
bilibili_shell_path=$dir_config/bilibili.json
bili_shell_path=$dir_script/bili_update.sh

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
    read -p "是否自动添加定时任务（添加或替换选项为 y，不替换为 n，回车为替换）请输入：" suqing
    suqing=${suqing:-'y'}
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
get_json_bilibili() {
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
    get_json_bilibili && dl_bilibili_shell
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
if ! [ -x "$(command -v java)" ]; then
   echo "开始安装Java运行环境........."
   apk update
   apk add openjdk8
fi
sleep 5
echo "依赖安装完成"

# 将 bilibilijay包 添加到定时任务
echo "尝试添加定时任务"
add_bilibili_jay() {
    if [ "$(grep -c "BILIBILI" /ql/config/crontab.list)" != 0 ]; then
        echo "您的任务列表中已存在 BILIBILI-HELPER"
    else
        echo "开始添加 BILIBILI定时任务"
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

if [ "${suqing}" = 'y' -o "${all}" = 1 ]; then
    add_bilibili_jay && run_bilibili_java
    echo "已为您添加定时任务"
else
    echo "已为您跳过添加定时任务"
fi

# 获取有效 更新文件 链接
get_sh_bili() {
    bili_list=(https://ghproxy.com/https://raw.githubusercontent.com/Tiziyi/bilibili/main/bili_update.sh https://raw.githubusercontent.com/Tiziyi/bilibili/main/bili_update.sh https://raw.sevencdn.com/Tiziyi/bilibili/main/bili_update.sh)
    for url in ${bili_list[@]}; do
        check_url $url
        if [ $? = 0 ]; then
            valid_url=$url
            echo "使用链接 $url"
            break
        fi
    done
}
# 下载 bili_update.sh
dl_bili_shell() {
    if [ ! -a "$bili_shell_path" ]; then
        touch $bili_shell_path
    fi
    curl -sL --connect-timeout 3 $valid_url > $bili_shell_path
    cp $bili_shell_path $dir_scripts/bili_update.sh
    # 判断是否下载成功
    bili_size=$(ls -l $bili_shell_path | awk '{print $5}')
    if (( $(echo "${bili_size} < 100" | bc -l) )); then
        echo "bili_update 下载失败"
        exit 0
    fi
}
if [ "${update}" = 'y' -o "${all}" = 1 ]; then
    get_sh_bili && dl_bili_shell
else
    echo "已为您跳过替换 task_before.sh"
fi


# 添加定时任务 自动更新
add_bili_update() {
    if [ "$(grep -c "bili_update" /ql/config/crontab.list)" != 0 ]; then
        echo "您的任务列表中已存在 bili_update"
    else
        echo "开始添加 bili_update"
        # 获取token
        token=$(cat /ql/config/auth.json | jq --raw-output .token)
        curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-Language: zh-CN,zh;q=0.9' --data-binary '{"name":"更新海尔破","command":"task bili_update.sh","schedule":"13 4 * * *"}' --compressed 'http://127.0.0.1:5700/api/crons?t=1626247933219'
    fi
}

if [ "${suqing}" = 'y' -o "${all}" = 1 ]; then
    add_bili_update
    echo "已为您添加自动更新定时任务"
else
    echo "已为您跳过添加自动更新定时任务"
fi

# 提示配置结束
echo -e "\n配置到此结束，请前往/ql/config/bilibili.json填入配置"
