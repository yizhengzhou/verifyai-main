# VerifyAI Raspberry Pi + Cloudflare Tunnel 部署指南

## 📋 目錄
- [系統需求](#系統需求)
- [快速開始](#快速開始)
- [詳細步驟](#詳細步驟)
- [自動化部署](#自動化部署)
- [監控與維護](#監控與維護)
- [疑難排解](#疑難排解)

---

## 系統需求

### 硬體需求
- **Raspberry Pi 3/4/5** (建議 2GB RAM 以上)
- **SD 卡**: 最少 16GB (建議 32GB)
- **網路**: 穩定的網路連接

### 軟體需求
- **OS**: Raspberry Pi OS (64-bit 建議) 或 Ubuntu Server
- **權限**: sudo 權限

---

## 快速開始

### 一鍵安裝腳本

```bash
# 1. 下載並執行自動安裝腳本
curl -fsSL https://raw.githubusercontent.com/yizhengzhou/verifyai-main/main/deployment/install.sh | bash

# 2. 按照提示完成 Cloudflare Tunnel 設定
cloudflared tunnel login
cloudflared tunnel create verifyai
cloudflared tunnel route dns verifyai verifyai.yourdomain.com

# 3. 啟動服務
sudo systemctl start verifyai-sync
sudo systemctl start cloudflared
```

**部署完成！** 🎉

---

## 詳細步驟

### 步驟 1: 準備 Raspberry Pi

```bash
# 更新系統
sudo apt update && sudo apt upgrade -y

# 安裝必要套件
sudo apt install -y nginx git curl

# 檢查服務狀態
sudo systemctl status nginx
```

---

### 步驟 2: 設定專案目錄

```bash
# 創建部署目錄
sudo mkdir -p /var/www/verifyai
sudo chown -R $USER:$USER /var/www/verifyai

# Clone repository
cd /var/www/verifyai
git clone https://github.com/yizhengzhou/verifyai-main.git .

# 設定權限
sudo chown -R www-data:www-data /var/www/verifyai
sudo chmod -R 755 /var/www/verifyai
```

---

### 步驟 3: 配置 Nginx

使用提供的 `nginx.conf` 配置檔：

```bash
# 複製配置檔
sudo cp /var/www/verifyai/deployment/nginx.conf /etc/nginx/sites-available/verifyai

# 創建軟連結
sudo ln -s /etc/nginx/sites-available/verifyai /etc/nginx/sites-enabled/

# 刪除預設配置（可選）
sudo rm /etc/nginx/sites-enabled/default

# 測試配置
sudo nginx -t

# 重新載入 Nginx
sudo systemctl reload nginx
```

---

### 步驟 4: 安裝 Cloudflare Tunnel

```bash
# 下載並安裝 cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared-linux-arm64.deb

# 驗證安裝
cloudflared --version
```

---

### 步驟 5: 設定 Cloudflare Tunnel

```bash
# 1. 登入 Cloudflare (會開啟瀏覽器)
cloudflared tunnel login

# 2. 創建 tunnel
cloudflared tunnel create verifyai

# 3. 記下 Tunnel ID (會顯示在輸出中)
# 範例: Created tunnel verifyai with id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# 4. 複製配置檔並填入您的 Tunnel ID
sudo cp /var/www/verifyai/deployment/cloudflared-config.yml ~/.cloudflared/config.yml

# 編輯配置檔，替換 YOUR_TUNNEL_ID 和 YOUR_DOMAIN
sudo nano ~/.cloudflared/config.yml

# 5. 設定 DNS 路由
cloudflared tunnel route dns verifyai verifyai.yourdomain.com

# 6. 測試 tunnel
cloudflared tunnel run verifyai
```

按 `Ctrl+C` 停止測試，如果沒有錯誤就繼續下一步。

---

### 步驟 6: 設定自動同步

```bash
# 安裝 systemd service
sudo cp /var/www/verifyai/deployment/verifyai-sync.service /etc/systemd/system/
sudo cp /var/www/verifyai/deployment/verifyai-sync.timer /etc/systemd/system/

# 重新載入 systemd
sudo systemctl daemon-reload

# 啟用並啟動 timer
sudo systemctl enable verifyai-sync.timer
sudo systemctl start verifyai-sync.timer

# 檢查狀態
sudo systemctl status verifyai-sync.timer
```

---

### 步驟 7: 設定 Cloudflare Tunnel 為系統服務

```bash
# 安裝為系統服務
sudo cloudflared service install

# 啟用並啟動服務
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# 檢查狀態
sudo systemctl status cloudflared
```

---

## 自動化部署

### GitHub Webhook (選項 A - 即時更新)

如果您希望每次 push 到 GitHub 就自動部署：

1. 在 Raspberry Pi 上安裝 webhook 服務器：
```bash
sudo cp /var/www/verifyai/deployment/webhook-server.py /usr/local/bin/
sudo cp /var/www/verifyai/deployment/webhook.service /etc/systemd/system/
sudo systemctl enable webhook
sudo systemctl start webhook
```

2. 在 GitHub repository 設定 webhook：
   - Settings → Webhooks → Add webhook
   - Payload URL: `https://verifyai.yourdomain.com/webhook`
   - Content type: `application/json`
   - Secret: 在 webhook-server.py 中設定的密鑰

### Cron Job (選項 B - 定時更新)

使用 systemd timer (已在步驟 6 設定)，預設每 10 分鐘檢查更新。

要修改頻率：
```bash
sudo nano /etc/systemd/system/verifyai-sync.timer
# 修改 OnCalendar= 這一行
sudo systemctl daemon-reload
sudo systemctl restart verifyai-sync.timer
```

---

## 監控與維護

### 查看服務狀態

```bash
# Nginx 狀態
sudo systemctl status nginx

# Cloudflare Tunnel 狀態
sudo systemctl status cloudflared

# 同步服務狀態
sudo systemctl status verifyai-sync.timer

# 查看同步日誌
journalctl -u verifyai-sync.service -f
```

### 查看 Nginx 日誌

```bash
# 訪問日誌
sudo tail -f /var/log/nginx/verifyai_access.log

# 錯誤日誌
sudo tail -f /var/log/nginx/verifyai_error.log
```

### 手動更新網站

```bash
cd /var/www/verifyai
sudo -u www-data git pull origin main
```

---

## 疑難排解

### 問題 1: Nginx 無法啟動

```bash
# 檢查配置
sudo nginx -t

# 查看錯誤日誌
sudo journalctl -u nginx -n 50

# 檢查端口是否被佔用
sudo netstat -tulpn | grep :80
```

### 問題 2: Cloudflare Tunnel 連接失敗

```bash
# 檢查 tunnel 狀態
cloudflared tunnel info verifyai

# 測試連接
cloudflared tunnel run verifyai

# 查看日誌
journalctl -u cloudflared -n 50
```

### 問題 3: Git pull 失敗

```bash
# 檢查 Git 配置
cd /var/www/verifyai
git config --list

# 重設 repository
git reset --hard origin/main
git clean -fd

# 檢查權限
ls -la /var/www/verifyai
```

### 問題 4: 網站更新沒有生效

```bash
# 清除瀏覽器快取
# 強制重新載入: Ctrl+Shift+R (Windows/Linux) 或 Cmd+Shift+R (Mac)

# 清除 Nginx 快取（如果有設定）
sudo rm -rf /var/cache/nginx/*
sudo systemctl reload nginx

# 檢查檔案是否真的更新了
ls -lh /var/www/verifyai/*.html
```

---

## 安全建議

### 1. 設定防火牆

```bash
# 安裝 ufw
sudo apt install ufw

# 只允許 SSH
sudo ufw allow ssh

# 啟用防火牆
sudo ufw enable

# 註：不需要開放 80/443 port，因為使用 Cloudflare Tunnel
```

### 2. 設定 fail2ban (防止暴力破解)

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. 定期更新系統

```bash
# 設定自動更新
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 4. 備份配置

```bash
# 創建備份目錄
mkdir ~/verifyai-backup

# 備份 Nginx 配置
sudo cp /etc/nginx/sites-available/verifyai ~/verifyai-backup/

# 備份 Cloudflare 配置
cp ~/.cloudflared/config.yml ~/verifyai-backup/
```

---

## 效能優化

### 1. 啟用 Gzip 壓縮

已在 `nginx.conf` 中配置，確保以下設定存在：

```nginx
gzip on;
gzip_types text/css application/javascript text/html;
gzip_min_length 1000;
```

### 2. 設定瀏覽器快取

已在 `nginx.conf` 中配置靜態資源快取。

### 3. 監控 Raspberry Pi 效能

```bash
# 安裝監控工具
sudo apt install htop

# 即時監控
htop

# 查看溫度
vcgencmd measure_temp

# 查看記憶體使用
free -h
```

---

## 進階功能

### 多分支部署

如果您想在同一台 Pi 上部署多個分支（例如 staging 和 production）：

```bash
# 複製 deployment 目錄
cp -r /var/www/verifyai /var/www/verifyai-staging

# 修改 Nginx 配置使用不同的 server_name
# 創建另一個 Cloudflare Tunnel
cloudflared tunnel create verifyai-staging
```

### 設定 CI/CD

參考 `.github/workflows/` 目錄中的 GitHub Actions 配置。

---

## 常用指令速查

```bash
# 重啟所有服務
sudo systemctl restart nginx cloudflared verifyai-sync

# 立即執行同步
sudo systemctl start verifyai-sync.service

# 查看所有相關服務狀態
systemctl status nginx cloudflared verifyai-sync.timer

# 查看即時日誌
journalctl -f -u nginx -u cloudflared -u verifyai-sync

# 測試網站連線
curl -I https://verifyai.yourdomain.com
```

---

## 聯絡與支援

如有任何問題，請：
1. 查看 [Cloudflare Tunnel 文件](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
2. 參考 [Nginx 官方文件](https://nginx.org/en/docs/)
3. 在 GitHub repository 開 issue

---

**部署完成！** 🎉

您的 VerifyAI landing page 現在應該已經在線上，並且會自動從 GitHub 同步更新。
