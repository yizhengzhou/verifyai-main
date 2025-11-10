# 🚀 快速更新到 i18n 版本

您的網站目前運行在: **https://verifyai.flaneuse.tw/**

由於您之前使用 `index.html`，現在要更新到新的多語言版本，請按照以下步驟操作：

---

## 方案 A：自動更新（推薦）⭐

在您的 Raspberry Pi 上執行：

```bash
# 1. SSH 連接到 Raspberry Pi
ssh pi@your-raspberry-pi-ip

# 2. 進入網站目錄
cd /var/www/verifyai

# 3. 拉取最新版本
sudo -u www-data git checkout main
sudo -u www-data git pull origin main

# 4. 執行更新腳本
sudo bash deployment/update-to-i18n.sh
```

**完成！** 🎉

訪問 https://verifyai.flaneuse.tw/ 測試語言切換功能。

---

## 方案 B：手動更新

如果自動腳本失敗，可以手動操作：

```bash
# 1. 進入目錄
cd /var/www/verifyai

# 2. 拉取最新版本
sudo -u www-data git pull origin main

# 3. 備份舊版
sudo cp index.html backup/index.html.backup

# 4. 創建符號連結（推薦）
sudo rm -f index.html
sudo ln -s verifyai-complete-final_4.html index.html

# 或者複製檔案
# sudo cp verifyai-complete-final_4.html index.html

# 5. 設定權限
sudo chown -h www-data:www-data index.html
sudo chown www-data:www-data translations.js translations-guide.md

# 6. 重新載入 Nginx
sudo nginx -t
sudo systemctl reload nginx
```

---

## 驗證更新

### 測試語言切換

1. 訪問 https://verifyai.flaneuse.tw/
2. 點擊導航列的語言選項：**中文 / English / 日本語 / 한국어**
3. 觀察整個頁面內容是否即時切換語言
4. 重新整理頁面，確認語言選擇被記住

### 檢查瀏覽器控制台

按 `F12` 開啟開發者工具，確認：
- ✅ 沒有 JavaScript 錯誤
- ✅ `translations.js` 成功載入
- ✅ 語言切換函數正常運作

### 測試多設備

- 📱 手機測試
- 💻 桌面測試
- 🌐 不同瀏覽器測試

---

## 如果遇到問題

### 問題 1: 頁面沒有變化

```bash
# 清除瀏覽器快取
# Chrome: Ctrl+Shift+Delete
# 或使用無痕模式測試

# 檢查檔案是否存在
cd /var/www/verifyai
ls -lh index.html verifyai-complete-final_4.html translations.js
```

### 問題 2: 語言切換不工作

```bash
# 檢查 translations.js 是否正確載入
curl https://verifyai.flaneuse.tw/translations.js

# 查看 Nginx 錯誤日誌
sudo tail -f /var/log/nginx/verifyai_error.log
```

### 問題 3: Git pull 失敗

```bash
# 重設 repository
cd /var/www/verifyai
sudo -u www-data git reset --hard origin/main
sudo -u www-data git pull origin main
```

---

## 回滾到舊版本

如果新版本有問題，可以快速回滾：

```bash
cd /var/www/verifyai
sudo cp backup/index.html.backup index.html
sudo systemctl reload nginx
```

---

## 設定自動更新（可選）

如果您還沒設定自動同步，可以執行：

```bash
# 安裝自動同步服務
cd /var/www/verifyai
sudo cp deployment/verifyai-sync.service /etc/systemd/system/
sudo cp deployment/verifyai-sync.timer /etc/systemd/system/

# 啟用服務
sudo systemctl daemon-reload
sudo systemctl enable verifyai-sync.timer
sudo systemctl start verifyai-sync.timer

# 檢查狀態
sudo systemctl status verifyai-sync.timer
```

現在每 10 分鐘會自動從 GitHub 同步更新！

---

## 檔案結構

更新後，您的目錄應該包含：

```
/var/www/verifyai/
├── index.html -> verifyai-complete-final_4.html (符號連結)
├── verifyai-complete-final_4.html (主 HTML 檔案)
├── translations.js (翻譯資源)
├── translations-guide.md (文案編輯指南)
├── deployment/ (部署配置)
│   ├── README.md
│   ├── nginx.conf
│   ├── sync.sh
│   └── ...
└── backup/ (備份目錄)
    └── index.html.backup
```

---

## 下一步

✅ 更新完成後：
1. 測試所有 4 種語言是否正常顯示
2. 檢查手機版顯示是否正常
3. 如需修改翻譯內容，參考 `translations-guide.md`

📚 完整文檔：
- 部署指南：`deployment/README.md`
- 翻譯編輯：`translations-guide.md`

---

**有任何問題？** 查看完整的疑難排解指南：`deployment/README.md`
