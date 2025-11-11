#!/bin/bash

# 使用方法: ./test-local.sh [端口號]
# 例如: ./test-local.sh 8080

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

# 檢查端口可用性的函數
check_port() {
    local port=$1
    if command -v netstat &> /dev/null; then
        netstat -tuln 2>/dev/null | grep -q ":$port "
        return $?
    elif command -v ss &> /dev/null; then
        ss -tuln 2>/dev/null | grep -q ":$port "
        return $?
    elif command -v lsof &> /dev/null; then
        lsof -i :$port &> /dev/null
        return $?
    else
        # 如果沒有這些工具，假設端口可用
        return 1
    fi
}

# 尋找可用端口
find_available_port() {
    local ports=(8000 8080 8888 3000 5000 9000)

    for port in "${ports[@]}"; do
        if ! check_port $port; then
            echo $port
            return 0
        fi
    done

    # 如果所有預設端口都被佔用，使用隨機端口
    echo $((8000 + RANDOM % 2000))
}

# 取得本機 IP 地址
get_local_ip() {
    # 嘗試多種方法獲取本機 IP
    if command -v hostname &> /dev/null; then
        hostname -I 2>/dev/null | awk '{print $1}'
    elif command -v ip &> /dev/null; then
        ip route get 1 2>/dev/null | awk '{print $7; exit}'
    else
        echo "localhost"
    fi
}

# 決定使用的端口
if [ -n "$1" ]; then
    PORT=$1
    echo "📌 使用指定的端口: $PORT"
else
    PORT=$(find_available_port)
    echo "🔍 自動選擇可用端口: $PORT"
fi

# 檢查端口是否被佔用
if check_port $PORT; then
    echo "⚠️  警告: 端口 $PORT 可能已被佔用"
    echo ""
    echo "請嘗試以下解決方案："
    echo "  1. 使用其他端口: ./test-local.sh 8080"
    echo "  2. 查看佔用端口的進程: sudo lsof -i :$PORT"
    echo "  3. 或者停止佔用該端口的服務"
    echo ""
    read -p "是否繼續嘗試啟動? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

LOCAL_IP=$(get_local_ip)

echo ""
echo "🚀 啟動本地 HTTP 服務器..."
echo ""
echo "📍 訪問方式："
echo "   本機瀏覽器: http://localhost:$PORT/index.html"
if [ "$LOCAL_IP" != "localhost" ]; then
    echo "   區域網內其他設備: http://$LOCAL_IP:$PORT/index.html"
fi
echo ""
echo "🌐 測試語言切換: 點擊導航欄的語言按鈕"
echo "🛑 停止服務器: 按 Ctrl+C"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

python3 -m http.server $PORT
