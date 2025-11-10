#!/bin/bash

# ============================================
# VerifyAI 一鍵安裝腳本
# ============================================
#
# 此腳本會自動安裝並配置：
# - Nginx web server
# - Git repository
# - Cloudflared tunnel client
# - Systemd services for auto-sync
#
# 使用方式:
# curl -fsSL https://raw.githubusercontent.com/yizhengzhou/verifyai-main/main/deployment/install.sh | bash
#
# 或下載後執行:
# chmod +x install.sh
# ./install.sh

set -e  # 發生錯誤時立即退出

# ============================================
# 配置
# ============================================

REPO_URL="https://github.com/yizhengzhou/verifyai-main.git"
REPO_DIR="/var/www/verifyai"
BRANCH="main"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# 輔助函數
# ============================================

print_header() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "請勿使用 root 執行此腳本"
        print_info "使用一般用戶執行，需要時會自動使用 sudo"
        exit 1
    fi
}

check_internet() {
    print_info "檢查網路連線..."
    if ! ping -c 1 google.com &> /dev/null; then
        print_error "無法連接到網際網路"
        exit 1
    fi
    print_success "網路連線正常"
}

detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        armv7l|armv6l)
            CLOUDFLARED_ARCH="arm"
            ;;
        aarch64|arm64)
            CLOUDFLARED_ARCH="arm64"
            ;;
        x86_64)
            CLOUDFLARED_ARCH="amd64"
            ;;
        *)
            print_error "不支援的架構: $ARCH"
            exit 1
            ;;
    esac
    print_success "偵測到架構: $ARCH (cloudflared: $CLOUDFLARED_ARCH)"
}

# ============================================
# 安裝步驟
# ============================================

install_dependencies() {
    print_header "步驟 1/6: 安裝系統套件"

    print_info "更新套件列表..."
    sudo apt update

    print_info "安裝必要套件..."
    sudo apt install -y nginx git curl wget

    print_success "系統套件安裝完成"
}

setup_repository() {
    print_header "步驟 2/6: 設定 Git Repository"

    # 創建目錄
    if [ -d "$REPO_DIR" ]; then
        print_info "目錄已存在: $REPO_DIR"
        read -p "是否刪除並重新 clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -rf "$REPO_DIR"
        else
            print_info "跳過 repository 設定"
            return
        fi
    fi

    print_info "創建目錄: $REPO_DIR"
    sudo mkdir -p "$REPO_DIR"
    sudo chown -R $USER:$USER "$REPO_DIR"

    print_info "Clone repository..."
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
    git checkout "$BRANCH"

    print_info "設定權限..."
    sudo chown -R www-data:www-data "$REPO_DIR"
    sudo chmod -R 755 "$REPO_DIR"

    print_success "Repository 設定完成"
}

configure_nginx() {
    print_header "步驟 3/6: 配置 Nginx"

    print_info "複製 Nginx 配置檔..."
    sudo cp "$REPO_DIR/deployment/nginx.conf" /etc/nginx/sites-available/verifyai

    print_info "啟用站點..."
    sudo ln -sf /etc/nginx/sites-available/verifyai /etc/nginx/sites-enabled/

    print_info "移除預設站點..."
    sudo rm -f /etc/nginx/sites-enabled/default

    print_info "測試 Nginx 配置..."
    if sudo nginx -t; then
        print_success "Nginx 配置正確"
        print_info "重新載入 Nginx..."
        sudo systemctl reload nginx
        sudo systemctl enable nginx
        print_success "Nginx 設定完成"
    else
        print_error "Nginx 配置錯誤"
        exit 1
    fi
}

install_cloudflared() {
    print_header "步驟 4/6: 安裝 Cloudflare Tunnel"

    if command -v cloudflared &> /dev/null; then
        print_info "cloudflared 已安裝"
        cloudflared --version
        return
    fi

    print_info "下載 cloudflared..."
    cd /tmp
    wget "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CLOUDFLARED_ARCH}.deb"

    print_info "安裝 cloudflared..."
    sudo dpkg -i "cloudflared-linux-${CLOUDFLARED_ARCH}.deb"

    print_success "cloudflared 安裝完成"
    cloudflared --version
}

setup_auto_sync() {
    print_header "步驟 5/6: 設定自動同步"

    print_info "設定 sync.sh 權限..."
    chmod +x "$REPO_DIR/deployment/sync.sh"

    print_info "安裝 systemd services..."
    sudo cp "$REPO_DIR/deployment/verifyai-sync.service" /etc/systemd/system/
    sudo cp "$REPO_DIR/deployment/verifyai-sync.timer" /etc/systemd/system/

    print_info "重新載入 systemd..."
    sudo systemctl daemon-reload

    print_info "啟用並啟動 timer..."
    sudo systemctl enable verifyai-sync.timer
    sudo systemctl start verifyai-sync.timer

    print_success "自動同步設定完成"
    sudo systemctl status verifyai-sync.timer --no-pager
}

configure_cloudflared() {
    print_header "步驟 6/6: 配置 Cloudflare Tunnel"

    print_info "現在需要手動完成以下步驟："
    echo ""
    echo "1. 登入 Cloudflare:"
    echo "   ${YELLOW}cloudflared tunnel login${NC}"
    echo ""
    echo "2. 創建 tunnel:"
    echo "   ${YELLOW}cloudflared tunnel create verifyai${NC}"
    echo ""
    echo "3. 記下顯示的 Tunnel ID"
    echo ""
    echo "4. 編輯配置檔並填入 Tunnel ID 和您的網域:"
    echo "   ${YELLOW}mkdir -p ~/.cloudflared${NC}"
    echo "   ${YELLOW}cp $REPO_DIR/deployment/cloudflared-config.yml ~/.cloudflared/config.yml${NC}"
    echo "   ${YELLOW}nano ~/.cloudflared/config.yml${NC}"
    echo ""
    echo "5. 設定 DNS 路由 (替換您的網域):"
    echo "   ${YELLOW}cloudflared tunnel route dns verifyai verifyai.yourdomain.com${NC}"
    echo ""
    echo "6. 測試 tunnel:"
    echo "   ${YELLOW}cloudflared tunnel run verifyai${NC}"
    echo ""
    echo "7. 如果測試成功，安裝為系統服務:"
    echo "   ${YELLOW}sudo cloudflared service install${NC}"
    echo "   ${YELLOW}sudo systemctl enable cloudflared${NC}"
    echo "   ${YELLOW}sudo systemctl start cloudflared${NC}"
    echo ""

    print_info "按 Enter 鍵開始 Cloudflare 登入流程..."
    read

    cloudflared tunnel login

    print_info "請按照上述步驟完成 tunnel 設定"
}

print_summary() {
    print_header "安裝完成！"

    echo "📋 摘要:"
    echo ""
    echo "✓ Nginx: 運行中"
    echo "✓ Git Repository: $REPO_DIR"
    echo "✓ 自動同步: 每 10 分鐘"
    echo ""
    echo "🔧 下一步:"
    echo "1. 完成 Cloudflare Tunnel 設定（如果尚未完成）"
    echo "2. 測試網站: curl http://localhost"
    echo "3. 查看服務狀態: sudo systemctl status nginx cloudflared verifyai-sync.timer"
    echo ""
    echo "📚 文件位置:"
    echo "- 完整指南: $REPO_DIR/deployment/README.md"
    echo "- Nginx 配置: /etc/nginx/sites-available/verifyai"
    echo "- 同步日誌: /var/log/verifyai-sync.log"
    echo ""
    echo "🎉 感謝使用 VerifyAI!"
}

# ============================================
# 主函數
# ============================================

main() {
    print_header "VerifyAI 自動安裝程式"

    check_root
    check_internet
    detect_arch

    install_dependencies
    setup_repository
    configure_nginx
    install_cloudflared
    setup_auto_sync
    configure_cloudflared

    print_summary
}

# ============================================
# 執行
# ============================================

main "$@"
