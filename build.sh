#!/bin/bash
# 构建脚本 - HealthOne Flutter 项目

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}"
APP_DIR="${PROJECT_DIR}/app"

echo "========================================"
echo "🚀 HealthOne 项目构建"
echo "========================================"

# 进入项目目录
cd "${APP_DIR}"

echo ""
echo "📦 步骤 1: 安装依赖..."
flutter pub get

echo ""
echo "🔧 步骤 2: 生成 Hive Adapter..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ 构建完成！"
echo ""
echo "🎯 下一步：运行应用"
echo "   flutter run"
echo ""
echo "📱 或在模拟器中运行"
echo "   flutter emulators --launch <emulator_id>"
echo "   flutter run"
echo ""
