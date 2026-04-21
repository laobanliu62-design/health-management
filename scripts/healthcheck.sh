#!/bin/bash
# HiClaw 系统健康检查脚本
# 用法: bash /root/scripts/healthcheck.sh
set -euo pipefail

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' NC='\033[0m'
FAIL=0

check_port() {
    local name=$1 port=$2 path=${3:-/}
    if curl -s --connect-timeout 2 "http://localhost:${port}${path}" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $name (:$port) 正常${NC}"
    else
        echo -e "${RED}❌ $name (:$port) 异常${NC}"
        FAIL=$((FAIL+1))
    fi
}

check_process() {
    local name=$1
    if pgrep -f "$name" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 进程 $name 运行中${NC}"
    else
        echo -e "${RED}❌ 进程 $name 未运行${NC}"
        FAIL=$((FAIL+1))
    fi
}

echo "========================================"
echo "  HiClaw 系统健康检查"
echo "  $(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S 北京时间')"
echo "========================================"

# 服务端口检查
echo ""
echo "📡 服务状态:"
check_port "Gateway" 18799 "/health"
check_port "雷达(企业搜索)" 8091 "/health"
check_port "Higress" 8080
check_port "MinIO Console" 9001
check_port "Matrix" 6167 "/_matrix/client/versions"

# 进程检查
echo ""
echo "🔄 进程状态:"
check_process "openclaw-gateway"
check_process "docker"

# Docker 检查
echo ""
echo "🐳 Docker:"
if docker ps >/dev/null 2>&1; then
    running=$(docker ps -q | wc -l)
    exited=$(docker ps -q -f status=exited | wc -l)
    echo -e "${GREEN}✅ Docker: ${running} 运行 / ${exited} 停止${NC}"
    for c in $(docker ps --format '{{.Names}}'); do
        status=$(docker inspect $c --format '{{.State.Status}}' 2>/dev/null)
        uptime=$(docker inspect $c --format '{{.State.StartedAt}}' 2>/dev/null | cut -dT -f1)
        echo -e "   📦 $c: $status (启动于 $uptime)"
    done
else
    echo -e "${RED}❌ Docker 未运行${NC}"
    FAIL=$((FAIL+1))
fi

# 磁盘检查
echo ""
echo "💾 磁盘:"
usage=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
avail=$(df -h / | awk 'NR==2{print $4}')
if [ "$usage" -gt 90 ]; then
    echo -e "${RED}❌ 磁盘使用 ${usage}% (剩余 ${avail})${NC}"
    FAIL=$((FAIL+1))
elif [ "$usage" -gt 80 ]; then
    echo -e "${YELLOW}⚠️ 磁盘使用 ${usage}% (剩余 ${avail})${NC}"
else
    echo -e "${GREEN}✅ 磁盘使用 ${usage}% (剩余 ${avail})${NC}"
fi

# 内存检查
echo ""
echo "🧠 内存:"
mem_total=$(free -m | awk 'NR==2{print $2}')
mem_used=$(free -m | awk 'NR==2{print $3}')
mem_pct=$((mem_used * 100 / mem_total))
echo -e "   使用: ${mem_used}MB / ${mem_total}MB (${mem_pct}%)"
if [ "$mem_pct" -gt 90 ]; then
    echo -e "${RED}❌ 内存使用过高${NC}"
    FAIL=$((FAIL+1))
fi

# 定时任务检查
echo ""
echo "⏰ 定时任务:"
crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | while read line; do
    echo -e "   📋 $line"
done

# 汇总
echo ""
echo "========================================"
if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}🎉 全部正常！0 个异常${NC}"
else
    echo -e "${RED}⚠️ 发现 ${FAIL} 个异常，请检查！${NC}"
fi
echo "========================================"

exit $FAIL