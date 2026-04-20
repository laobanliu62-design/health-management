#!/bin/bash
# HicLaw 企业搜索服务启动脚本
cd /root/hiclaw-services/company-search
while true; do
    echo "[$(date)] 启动 hiclaw-company-search..."
    /usr/bin/python3 main.py
    echo "[$(date)] 进程退出，5秒后重启..."
    sleep 5
done
