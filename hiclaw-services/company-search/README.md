# 📡 雷达 - HicLaw 企业搜索服务

## 口令
- "雷达，查 [公司名]"
- "雷达，帮我查 [公司名]"
- "雷达，扫描 [公司名]"

## 接口
- 端口: 8091
- 搜索: GET /api/company/search/raw?name=公司名&domain=域名(可选)
- 健康: GET /health
- 文档: http://localhost:8091/docs

## 数据源
1. 官网爬取 (名称/邮箱/电话/简介/行业)
2. Wikipedia (国家/成立日期/简介)
3. OpenCorporates (注册地址/公司编码 - 需API Token)
4. Crunchbase (行业/融资 - 反爬403，待优化)

## 启动
- 自动启动: crontab @reboot
- 崩溃重启: start.sh while循环 5秒
- 日志: /tmp/hiclaw-company-search.log