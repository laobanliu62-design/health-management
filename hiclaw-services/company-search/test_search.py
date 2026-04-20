"""HicLaw 企业搜索 - 测试脚本"""
import asyncio
import httpx
import json
import time


async def test_search():
    """测试 Kiefer Aquatics 搜索"""
    base = "http://localhost:8001"
    
    # 先检查健康
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"{base}/health")
        print(f"健康检查: {resp.json()}")
        
        # 搜索企业
        print("\n🔍 搜索 Kiefer Aquatics...")
        start = time.time()
        resp = await client.get(
            f"{base}/api/company/search/raw",
            params={"name": "Kiefer Aquatics", "domain": "kiefer.com"}
        )
        elapsed = time.time() - start
        
        data = resp.json()
        print(f"\n⏱️ 耗时: {elapsed:.1f}s")
        print(f"\n📋 结果:\n{json.dumps(data, indent=2, ensure_ascii=False)}")
        
        # 统计填充率
        filled = sum(1 for v in data.values() if v)
        total = len(data)
        print(f"\n📊 字段填充率: {filled}/{total} ({filled/total*100:.0f}%)")


if __name__ == "__main__":
    asyncio.run(test_search())