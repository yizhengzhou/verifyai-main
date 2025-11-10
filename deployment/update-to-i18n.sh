#!/bin/bash

# ============================================
# VerifyAI 更新到 i18n 版本腳本
# ============================================
#
# 此腳本會：
# 1. 備份舊的 index.html
# 2. 將 verifyai-complete-final_4.html 設為主頁面
# 3. 重新載入 Nginx
#
# 適用於已經部署並使用 index.html 的情況

set -e

REPO_DIR="/var/www/verifyai"
BACKUP_DIR="/var/www/verifyai/backup"

# 顏色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}準備更新到 i18n 版本...${NC}"

# 進入專案目錄
cd "$REPO_DIR"

# 拉取最新版本
echo "📥 拉取最新版本..."
sudo -u www-data git pull origin main

# 創建備份目錄
echo "💾 備份舊版本..."
mkdir -p "$BACKUP_DIR"
if [ -f "index.html" ]; then
    sudo cp index.html "$BACKUP_DIR/index.html.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓ 已備份 index.html${NC}"
fi

# 方案 A: 創建符號連結 (推薦)
echo "🔗 創建 index.html 符號連結..."
sudo rm -f index.html
sudo ln -s verifyai-complete-final_4.html index.html

# 或方案 B: 複製檔案 (取消註解下面兩行，並註解上面兩行)
# echo "📋 複製新版本為 index.html..."
# sudo cp verifyai-complete-final_4.html index.html

# 設定權限
echo "🔐 設定權限..."
sudo chown -h www-data:www-data index.html
sudo chown -R www-data:www-data translations.js translations-guide.md

# 測試 Nginx 配置
echo "🧪 測試 Nginx 配置..."
sudo nginx -t

# 重新載入 Nginx
echo "🔄 重新載入 Nginx..."
sudo systemctl reload nginx

echo ""
echo -e "${GREEN}✅ 更新完成！${NC}"
echo ""
echo "📊 檔案狀態:"
ls -lh index.html verifyai-complete-final_4.html translations.js
echo ""
echo "🌐 請訪問 https://verifyai.flaneuse.tw/ 測試"
echo "🔤 測試語言切換功能：點擊導航列的語言選項"
echo ""
echo "💡 如需回滾:"
echo "   sudo cp $BACKUP_DIR/index.html.[timestamp] $REPO_DIR/index.html"
echo "   sudo systemctl reload nginx"
