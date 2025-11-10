#!/bin/bash

# ============================================
# VerifyAI Git Sync Script
# ============================================
#
# 此腳本會：
# 1. 從 GitHub 拉取最新版本
# 2. 檢查是否有更新
# 3. 如果有更新，重新載入 Nginx
#
# 使用方式:
# chmod +x sync.sh
# ./sync.sh
#
# 或由 systemd timer 自動執行

set -e  # 發生錯誤時立即退出

# ============================================
# 配置
# ============================================

REPO_DIR="/var/www/verifyai"
BRANCH="main"
LOG_FILE="/var/log/verifyai-sync.log"
NGINX_RELOAD=true

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# 日誌函數
# ============================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# ============================================
# 主要邏輯
# ============================================

main() {
    log_info "Starting VerifyAI sync..."

    # 檢查目錄是否存在
    if [ ! -d "$REPO_DIR" ]; then
        log_error "Repository directory does not exist: $REPO_DIR"
        exit 1
    fi

    cd "$REPO_DIR" || exit 1

    # 檢查是否為 Git repository
    if [ ! -d ".git" ]; then
        log_error "Not a git repository: $REPO_DIR"
        exit 1
    fi

    # 記錄當前 commit
    OLD_COMMIT=$(git rev-parse HEAD)
    log_info "Current commit: $OLD_COMMIT"

    # 拉取遠端更新
    log_info "Fetching from remote..."
    if ! git fetch origin "$BRANCH"; then
        log_error "Failed to fetch from remote"
        exit 1
    fi

    # 檢查是否有更新
    REMOTE_COMMIT=$(git rev-parse "origin/$BRANCH")
    log_info "Remote commit: $REMOTE_COMMIT"

    if [ "$OLD_COMMIT" = "$REMOTE_COMMIT" ]; then
        log_info "No updates available. Already up to date."
        exit 0
    fi

    # 有更新，執行 pull
    log_info "New updates found. Pulling changes..."

    # 儲存本地修改（如果有）
    if ! git diff --quiet; then
        log_info "Stashing local changes..."
        git stash
    fi

    # 執行 pull
    if ! git pull origin "$BRANCH"; then
        log_error "Failed to pull from remote"
        exit 1
    fi

    NEW_COMMIT=$(git rev-parse HEAD)
    log_success "Updated from $OLD_COMMIT to $NEW_COMMIT"

    # 顯示更新內容
    log_info "Changes:"
    git log --oneline "$OLD_COMMIT..$NEW_COMMIT" | tee -a "$LOG_FILE"

    # 重新載入 Nginx
    if [ "$NGINX_RELOAD" = true ]; then
        log_info "Reloading Nginx..."
        if sudo systemctl reload nginx; then
            log_success "Nginx reloaded successfully"
        else
            log_error "Failed to reload Nginx"
        fi
    fi

    log_success "Sync completed successfully!"
}

# ============================================
# 錯誤處理
# ============================================

trap 'log_error "Script failed at line $LINENO"' ERR

# ============================================
# 執行
# ============================================

main "$@"
