# PowerShell 脚本 - 从 WSL 访问健康管理系统
# 运行方式：在 Windows PowerShell 中执行

Write-Host "================================" -ForegroundColor Cyan
Write-Host "OpenClaw 健康管理系统访问" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 检查 WSL 路径
$wslPath = "\\wsl$\Ubuntu\root\health-management"

if (Test-Path $wslPath) {
    Write-Host "✅ 找到 WSL 共享路径！" -ForegroundColor Green
    Write-Host ""
    Write-Host "正在打开文件夹..." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList $wslPath
} else {
    Write-Host "❌ WSL 共享路径不可用" -ForegroundColor Red
    Write-Host ""
    Write-Host "请尝试以下方法访问文件：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "方法 1: 直接访问本地路径" -ForegroundColor Cyan
    Write-Host "  D:\health-management\" -ForegroundColor White
    Write-Host ""
    Write-Host "方法 2: 使用命令行访问" -ForegroundColor Cyan
    Write-Host "  wsl -d Ubuntu ls /root/health-management" -ForegroundColor Gray
}

Write-Host ""
Write-Host "按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
