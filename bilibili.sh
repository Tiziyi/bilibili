#!/usr/bin/env bash


dir_config=/ql/config
dir_script=/ql/scripts
bilibili_shell_path=$dir_config/bilibili.json
bili_shell_path=$dir_script/bili.sh

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

# 获取有效 config.sh 链接
get_valid_bilibili() {
    bilibili_list=(https://raw.githubusercontent.com/Tiziyi/bilibili/main/bilibili.json https://raw.sevencdn.com/Tiziyi/bilibili/main/bilibili.json https://ghproxy.com/https://raw.githubusercontent.com/Tiziyi/bilibili/main/bilibili.json)
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
    curl -sL --connect-timeout 3 $valid_url > $bili_shell_path
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


# 提示配置结束
echo -e "\n配置到此结束，您是否成功了呢？"
