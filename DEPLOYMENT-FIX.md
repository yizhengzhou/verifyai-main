# i18n.js 404 錯誤修復記錄

## 問題描述

用戶報告兩個問題：
1. `i18n.js:1  Failed to load resource: the server responded with a status of 404 ()`
2. 網頁變得不完整

## 根本原因

開發環境的文件位於 `/home/user/verifyai-main/`，但 Nginx 配置要求從 `/var/www/verifyai/` 提供服務。由於部署目錄不存在或未同步，導致 i18n.js 和相關資源無法載入。

## 修復步驟

### 1. 創建部署目錄並複製文件

```bash
mkdir -p /var/www/verifyai
cp -r /home/user/verifyai-main/* /var/www/verifyai/
```

### 2. 設置正確的文件權限

```bash
chmod -R 755 /var/www/verifyai
chmod 644 /var/www/verifyai/*.html
chmod 644 /var/www/verifyai/js/*.js
chmod 644 /var/www/verifyai/locales/*.json
```

### 3. 驗證文件結構

部署後的目錄結構：

```
/var/www/verifyai/
├── index.html
├── verifyai-complete-final_4.html
├── test-i18n.html
├── js/
│   ├── i18n.js
│   └── smooth-scroll.js
└── locales/
    ├── zh-TW.json
    ├── en.json
    ├── ja.json
    └── ko.json
```

## 驗證

### 檢查文件是否存在

```bash
ls -la /var/www/verifyai/js/
ls -la /var/www/verifyai/locales/
```

### 測試文件訪問

訪問以下 URL 應該返回 200 狀態碼：
- `http://localhost/js/i18n.js`
- `http://localhost/locales/zh-TW.json`
- `http://localhost/index.html`

## 未來部署流程

### 方案 A: 手動同步

每次更新代碼後執行：

```bash
cp -r /home/user/verifyai-main/* /var/www/verifyai/
chmod -R 755 /var/www/verifyai
```

### 方案 B: 使用 Git 直接部署

將 `/var/www/verifyai/` 初始化為 Git 倉庫並直接拉取：

```bash
cd /var/www/verifyai
git init
git remote add origin <repository-url>
git pull origin main
```

### 方案 C: 使用同步腳本

使用項目中提供的 `deployment/sync.sh` 腳本。

## Nginx 配置

確認 Nginx 配置正確指向部署目錄：

```nginx
root /var/www/verifyai;
index verifyai-complete-final_4.html index.html;
```

配置位置：`/etc/nginx/sites-available/verifyai`

## 相關文件

- Nginx 配置：`deployment/nginx.conf`
- 同步腳本：`deployment/sync.sh`
- i18n 更新腳本：`deployment/update-to-i18n.sh`

## 修復日期

2025-11-11

## 狀態

✅ 已修復並部署
