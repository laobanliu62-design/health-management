#!/usr/bin/env python3
"""
HicLaw 企业搜索服务 - 多源聚合
数据源: 官网爬取 + Crunchbase + OpenCorporates
输出: 标准 JSON
"""

import re
import json
import asyncio
from typing import Optional
from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import httpx
from bs4 import BeautifulSoup

app = FastAPI(
    title="HicLaw 企业搜索 API",
    description="多源聚合企业信息搜索接口",
    version="1.0.0",
)


class CompanyInfo(BaseModel):
    """企业信息标准输出模型"""
    企业名称: Optional[str] = None
    所在国家: Optional[str] = None
    行业: Optional[str] = None
    公司运营状态: Optional[str] = None
    行业描述: Optional[str] = None
    公司主要业务线: Optional[list] = None
    商业描述: Optional[str] = None
    经营地址: Optional[str] = None
    注册地址: Optional[str] = None
    企业邮箱: Optional[str] = None
    企业电话: Optional[str] = None
    官网地址: Optional[str] = None
    公司成立日期: Optional[str] = None
    注册资本: Optional[str] = None
    实缴资本: Optional[str] = None
    公司编码: Optional[str] = None
    公司简介: Optional[str] = None
    数据来源: Optional[list] = None


# ============================================================
# 数据源 1: 官网爬取
# ============================================================

async def fetch_website_info(domain: str) -> dict:
    """从公司官网抓取基础信息"""
    result = {}
    sources = []
    
    # 尝试多个域名变体
    domains_to_try = [
        f"https://www.{domain}",
        f"https://{domain}",
    ]
    
    async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
        # 找到可用的域名
        base_url = None
        for d in domains_to_try:
            try:
                resp = await client.get(d, headers={"User-Agent": "Mozilla/5.0"})
                if resp.status_code == 200:
                    base_url = d
                    break
            except:
                continue
        
        if not base_url:
            return {"数据来源": []}
        
        result["官网地址"] = base_url
        sources.append(f"官网({base_url})")
        
        # 如果网站能打开，推断运营状态为"运营中"
        result["公司运营状态"] = "运营中 (Active)"
        
        # 抓取首页
        try:
            resp = await client.get(base_url, headers={"User-Agent": "Mozilla/5.0"})
            soup = BeautifulSoup(resp.text, "lxml")
            
            # 提取网站标题作为企业名称
            title = soup.find("title")
            if title:
                name = title.text.split("–")[0].split("|")[0].strip()
                if name:
                    result["企业名称"] = name
            
            # 提取 meta description
            meta_desc = soup.find("meta", attrs={"name": "description"})
            if meta_desc and meta_desc.get("content"):
                result["商业描述"] = meta_desc["content"].strip()
            
            # 从 meta description 推断行业
            desc_lower = meta_desc["content"].lower() if meta_desc else ""
            industry_map = {
                "swimwear": "水上运动用品", "swimming": "水上运动", "aquatic": "水上运动",
                "software": "软件", "technology": "科技", "healthcare": "医疗健康",
                "pharmaceutical": "制药", "financial": "金融", "retail": "零售",
                "ecommerce": "电子商务", "food": "食品饮料", "automotive": "汽车",
                "energy": "能源", "education": "教育", "manufacturing": "制造",
            }
            for kw, ind in industry_map.items():
                if kw in desc_lower:
                    result["行业"] = ind
                    result["行业描述"] = f"主营{ind}相关产品和服务"
                    break
        except:
            pass
        
        # 抓取 About 页面
        for about_path in ["/pages/about-us", "/about", "/about-us", "/company", "/about-us/", "/company/"]:
            try:
                resp = await client.get(
                    f"{base_url}{about_path}",
                    headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64)"}
                )
                if resp.status_code == 200:
                    soup = BeautifulSoup(resp.text, "lxml")
                    text = soup.get_text(separator="\n", strip=True)
                    
                    # 提取公司简介 - 只取 About 区域内的有意义内容
                    noise = ("BOGO", "SALE", "SHOP", "FREE", "DISCOUNT", "✓", "→", "©",
                             "Add to", "away from being", "Tax included", "Shipping calculated",
                             "Excludes mesh", "Your cart", "Subtotal", "Checkout",
                             "You're", "items", "Qty", "Log in", "Sign up", "Search",
                             "Menu", "Close", "Home", "Back", "Next", "Previous",
                             "Sort by", "Filter", "View", "Compare", "Wishlist",
                             "Discount automatically", "cart", "Check out")
                    about_lines = []
                    in_about = False
                    for l in text.split("\n"):
                        l = l.strip()
                        # 检测 About 区域开始
                        if re.match(r'^(About|Our Story|About Us|Company|Who We Are)', l, re.I):
                            in_about = True
                            continue
                        # 检测 About 区域结束
                        if in_about and re.match(r'^(Shop|Products|Categories|Follow|Newsletter|Sign Up|Contact|Footer)', l, re.I):
                            in_about = False
                            continue
                        if in_about and len(l) > 40 and not any(l.startswith(ns) for ns in noise):
                            about_lines.append(l)
                    
                    # 如果没找到 About 区域，用全文但严格过滤
                    if not about_lines:
                        for l in text.split("\n"):
                            l = l.strip()
                            if len(l) > 60 and not any(ns in l for ns in noise):
                                about_lines.append(l)
                    
                    if about_lines:
                        about_text = " ".join(about_lines[:6])
                        if len(about_text) > 100:
                            result["公司简介"] = about_text
                    
                    # 提取成立年份
                    founded = re.search(r'(?:founded|established|created|started)\s+(?:in\s+)?(\d{4})', text, re.I)
                    if founded:
                        result["公司成立日期"] = founded.group(1)
                    
                    # 提取国家
                    country_patterns = [
                        r'(?:based in|headquartered in|located in)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
                        r'(?:USA|United States|United Kingdom|Canada|Australia|Germany|China|Japan)',
                    ]
                    for p in country_patterns:
                        m = re.search(p, text, re.I)
                        if m:
                            result["所在国家"] = m.group(0) if m.lastindex is None else m.group(1)
                            break
                    
                    break
            except:
                continue
        
        # 抓取 Contact 页面
        for contact_path in ["/pages/contact-us", "/contact", "/contact-us"]:
            try:
                resp = await client.get(
                    f"{base_url}{contact_path}",
                    headers={"User-Agent": "Mozilla/5.0"}
                )
                if resp.status_code == 200:
                    soup = BeautifulSoup(resp.text, "lxml")
                    text = soup.get_text(separator="\n", strip=True)
                    
                    # 提取邮箱
                    emails = re.findall(r'[\w.+-]+@[\w-]+\.[\w.]+', text)
                    if emails:
                        result["企业邮箱"] = emails[0]
                    
                    # 提取电话
                    phones = re.findall(r'(?:\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', text)
                    if phones:
                        result["企业电话"] = phones[0]
                    
                    # 提取地址
                    addr_match = re.search(
                        r'\d+\s+[\w\s]+(?:St|Ave|Blvd|Dr|Ln|Rd|Ct|Way|Pkwy)[\w\s,]+(?:\d{5})',
                        text
                    )
                    if addr_match:
                        result["经营地址"] = addr_match.group().strip()
                    break
            except:
                continue
    
    result["数据来源"] = sources
    return result


# ============================================================
# 数据源 2: OpenCorporates (免费API - 需要token或用旧版免认证接口)
# ============================================================

async def fetch_opencorporates_info(company_name: str) -> dict:
    """从 OpenCorporates 搜索企业注册信息"""
    result = {}
    sources = []
    
    async with httpx.AsyncClient(timeout=15) as client:
        try:
            # 尝试免认证搜索 (旧版 API)
            resp = await client.get(
                "https://api.opencorporates.com/v0.4/companies/search",
                params={"q": company_name}
            )
            if resp.status_code == 200:
                data = resp.json()
                companies = data.get("results", {}).get("companies", [])
                
                if companies:
                    company = companies[0].get("company", {})
                    
                    if company.get("name"):
                        result["企业名称"] = company["name"]
                    if company.get("jurisdiction_code"):
                        result["所在国家"] = company["jurisdiction_code"].upper().replace("_", " ")
                    if company.get("company_type"):
                        result["行业"] = company["company_type"]
                    if company.get("current_status"):
                        result["公司运营状态"] = company["current_status"]
                    if company.get("registered_address"):
                        addr = company["registered_address"]
                        if isinstance(addr, dict):
                            result["注册地址"] = addr.get("full_address", "")
                        elif isinstance(addr, str):
                            result["注册地址"] = addr
                    if company.get("incorporation_date"):
                        result["公司成立日期"] = company["incorporation_date"]
                    if company.get("company_number"):
                        result["公司编码"] = company["company_number"]
                    
                    sources.append("OpenCorporates")
                    
                    # 获取详细信息
                    oc_url = company.get("opencorporates_url")
                    if oc_url:
                        try:
                            detail_resp = await client.get(f"{oc_url}.json")
                            detail = detail_resp.json()
                            c = detail.get("results", {}).get("company", {})
                            if c.get("industry_codes"):
                                codes = c["industry_codes"]
                                if isinstance(codes, list) and codes:
                                    result["行业描述"] = codes[0].get("industry_code", {}).get("description", "")
                        except:
                            pass
            else:
                sources.append(f"OpenCorporates(skipped: {resp.status_code})")
        except Exception as e:
            sources.append(f"OpenCorporates(error: {str(e)[:50]})")
    
    result["数据来源"] = sources
    return result


# ============================================================
# 数据源 3: Wikipedia (免费可靠)
# ============================================================

async def fetch_wikipedia_info(company_name: str) -> dict:
    """从 Wikipedia 搜索企业/创始人信息"""
    result = {}
    sources = []
    
    async with httpx.AsyncClient(timeout=15, follow_redirects=True,
                                   headers={"User-Agent": "HicLawCompanySearch/1.0 (https://hiclaw.ai; contact@hiclaw.ai)",
                                            "Accept": "application/json"}) as client:
        try:
            # 先搜索
            resp = await client.get(
                "https://en.wikipedia.org/w/api.php",
                params={
                    "action": "query",
                    "list": "search",
                    "srsearch": company_name,
                    "format": "json",
                    "srlimit": 3,
                }
            )
            if resp.status_code != 200:
                sources.append(f"Wikipedia(search: {resp.status_code})")
                result["数据来源"] = sources
                return result
                
            try:
                data = resp.json()
            except:
                sources.append("Wikipedia(parse error)")
                result["数据来源"] = sources
                return result
            search_results = data.get("query", {}).get("search", [])
            
            if not search_results:
                sources.append("Wikipedia(no results)")
                result["数据来源"] = sources
                return result
            
            # 取最相关的结果
            for sr in search_results[:3]:
                title = sr.get("title", "")
                page_resp = await client.get(
                    "https://en.wikipedia.org/w/api.php",
                    params={
                        "action": "query",
                        "titles": title,
                        "prop": "extracts|info|revisions",
                        "inprop": "url",
                        "exintro": True,
                        "explaintext": True,
                        "format": "json",
                    }
                )
                page_data = page_resp.json()
                pages = page_data.get("query", {}).get("pages", {})
                
                for page_id, page in pages.items():
                    extract = page.get("extract", "")
                    if not extract or len(extract) < 50:
                        continue
                    
                    # 提取国家
                    country_match = re.search(
                        r'(American|British|Canadian|Australian|German|Chinese|Japanese|French|Indian)\b',
                        extract
                    )
                    if country_match:
                        nat = country_match.group(1)
                        country_map = {
                            "American": "美国", "British": "英国", "Canadian": "加拿大",
                            "Australian": "澳大利亚", "German": "德国", "Chinese": "中国",
                            "Japanese": "日本", "French": "法国", "Indian": "印度",
                        }
                        result["所在国家"] = country_map.get(nat, nat)
                    
                    # 提取成立年份
                    founded = re.search(r'(?:founded|established|created|started|in)\s+(\d{4})', extract)
                    if founded:
                        result["公司成立日期"] = founded.group(1)
                    
                    # 提取行业
                    industry_keywords = {
                        "swim": "水上运动", "aquatic": "水上运动", "technology": "科技",
                        "software": "软件", "pharmaceutical": "制药", "automotive": "汽车",
                        "financial": "金融", "retail": "零售", "manufacturing": "制造",
                        "healthcare": "医疗健康", "energy": "能源", "food": "食品",
                        "ecommerce": "电子商务", "e-commerce": "电子商务",
                    }
                    for kw, ind in industry_keywords.items():
                        if kw in extract.lower():
                            result["行业"] = ind
                            break
                    
                    # 简介
                    if len(extract) > 100:
                        result["公司简介"] = extract[:500].strip()
                    
                    sources.append(f"Wikipedia({title})")
                    break
                
                if result.get("公司简介"):
                    break
                    
        except Exception as e:
            sources.append(f"Wikipedia(error: {str(e)[:50]})")
    
    result["数据来源"] = sources
    return result


# ============================================================
# 数据源 4: Crunchbase (网页爬取 - 可能被反爬)
# ============================================================

async def fetch_crunchbase_info(company_name: str) -> dict:
    """从 Crunchbase 网页抓取企业信息"""
    result = {}
    sources = []
    
    slug = company_name.lower().replace(" ", "-")
    
    async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
        try:
            resp = await client.get(
                f"https://www.crunchbase.com/organization/{slug}",
                headers={
                    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"
                }
            )
            if resp.status_code == 200:
                soup = BeautifulSoup(resp.text, "lxml")
                
                # 提取 JSON-LD 数据
                scripts = soup.find_all("script", type="application/ld+json")
                for script in scripts:
                    try:
                        ld_data = json.loads(script.string)
                        if ld_data.get("name"):
                            result["企业名称"] = ld_data["name"]
                        if ld_data.get("description"):
                            result["公司简介"] = ld_data["description"]
                        if ld_data.get("foundingDate"):
                            result["公司成立日期"] = ld_data["foundingDate"]
                        if ld_data.get("address"):
                            result["经营地址"] = ld_data["address"]
                    except:
                        pass
                
                # 从页面文本提取信息
                text = soup.get_text(separator="\n", strip=True)
                
                # 行业
                for keyword in ["Industries:", "Industry:", "Categories:"]:
                    idx = text.find(keyword)
                    if idx > -1:
                        line = text[idx:idx+100].split("\n")[0]
                        result["行业"] = line.replace(keyword, "").strip()
                        break
                
                # 总部
                for keyword in ["Headquarters:", "HQ:"]:
                    idx = text.find(keyword)
                    if idx > -1:
                        line = text[idx:idx+100].split("\n")[0]
                        result["经营地址"] = line.replace(keyword, "").strip()
                        break
                
                # 成立日期
                for keyword in ["Founded:", "Founded Date:"]:
                    idx = text.find(keyword)
                    if idx > -1:
                        line = text[idx:idx+50].split("\n")[0]
                        result["公司成立日期"] = line.replace(keyword, "").strip()
                        break
                
                # 运营状态
                for keyword in ["Operating Status:", "Status:"]:
                    idx = text.find(keyword)
                    if idx > -1:
                        line = text[idx:idx+50].split("\n")[0]
                        result["公司运营状态"] = line.replace(keyword, "").strip()
                        break
                
                sources.append("Crunchbase")
        except Exception as e:
            sources.append(f"Crunchbase(error: {str(e)[:50]})")
    
    result["数据来源"] = sources
    return result


# ============================================================
# 多源聚合
# ============================================================

async def aggregate_company_info(name: str, domain: str = None) -> CompanyInfo:
    """聚合多源数据，按优先级合并"""
    
    tasks = []
    
    # 总是查询所有数据源
    tasks.append(fetch_opencorporates_info(name))
    tasks.append(fetch_wikipedia_info(name))
    tasks.append(fetch_crunchbase_info(name))
    
    # 如果提供了域名，爬官网
    if domain:
        tasks.append(fetch_website_info(domain))
    
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    # 合并数据（后面的覆盖前面的空值）
    merged = {}
    all_sources = []
    
    # 优先级: 官网 > OpenCorporates > Crunchbase
    for r in results:
        if isinstance(r, Exception):
            continue
        sources = r.pop("数据来源", [])
        all_sources.extend(sources)
        for k, v in r.items():
            if v and (k not in merged or not merged[k]):
                merged[k] = v
    
    merged["数据来源"] = all_sources
    return CompanyInfo(**merged)


# ============================================================
# API 路由
# ============================================================

@app.get("/api/company/search", response_model=CompanyInfo)
async def search_company(
    name: str = Query(..., description="企业名称 (如: Kiefer Aquatics)"),
    domain: str = Query(None, description="企业域名 (如: kieferaquatics.com)"),
):
    """
    搜索企业信息 - 多源聚合
    
    数据源: 官网 + OpenCorporates + Crunchbase
    输出: 标准 JSON
    """
    result = await aggregate_company_info(name, domain)
    return result


@app.get("/api/company/search/raw")
async def search_company_raw(
    name: str = Query(..., description="企业名称"),
    domain: str = Query(None, description="企业域名"),
):
    """搜索企业信息 - 返回原始 JSON (含中文字段)"""
    result = await aggregate_company_info(name, domain)
    return JSONResponse(content=result.model_dump(exclude_none=False))


@app.get("/health")
async def health():
    return {"status": "ok", "service": "hiclaw-company-search", "version": "1.0.0"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8091)