#!/usr/bin/env bash
dir_config=/ql/config
dir_script=/ql/scripts
dir_bilibili=$dir_config/bilibili.json

# 获取有效 config.sh 链接
get_valid_config() {
    config_list=(https://raw.githubusercontent.com/Tiziyi/bilibili/main/bilibili.json)
    for url in ${config_list[@]}; do
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
    if [ ! -a "$dir_bilibili" ]; then
        touch $dir_bilibili
    fi
    curl -sL --connect-timeout 3 $valid_url > $dir_bilibili
    cp $dir_bilibili $dir_config/bilibili.json
    # 判断是否下载成功
    config_size=$(ls -l $dir_bilibili | awk '{print $5}')
    if (( $(echo "${config_size} < 100" | bc -l) )); then
        echo "config.sh 下载失败"
        exit 0
    fi
}
