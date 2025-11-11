#!/bin/bash

echo "🔍 檢查 i18n 文件..."
echo ""

# 檢查文件存在
if [ ! -f "js/i18n.js" ]; then
    echo "❌ js/i18n.js 不存在！"
    exit 1
else
    echo "✅ js/i18n.js 存在"
fi

if [ ! -d "locales" ]; then
    echo "❌ locales/ 目錄不存在！"
    exit 1
else
    echo "✅ locales/ 目錄存在"
fi

# 檢查語言文件
for lang in zh-TW en ja ko; do
    if [ ! -f "locales/${lang}.json" ]; then
        echo "❌ locales/${lang}.json 不存在！"
        exit 1
    else
        echo "✅ locales/${lang}.json 存在"
    fi
done

echo ""
echo "🎉 所有 i18n 文件都存在！"
echo ""
echo "📁 文件大小："
ls -lh js/i18n.js locales/*.json
echo ""
echo "🚀 啟動本地 HTTP 服務器..."
echo "📍 請在瀏覽器訪問: http://localhost:8000/index.html"
echo "🌐 測試語言切換: 點擊導航欄的語言按鈕"
echo "🛑 停止服務器: 按 Ctrl+C"
echo ""

python3 -m http.server 8000
