# i18n.js 404 錯誤診斷與修復指南

## 問題描述

瀏覽器 Console 顯示：
```
i18n.js:1  Failed to load resource: the server responded with a status of 404 ()
```

## 🚀 快速修復（推薦）

如果端口被佔用，使用更新的測試腳本：

```bash
cd /home/yizheng/verifyai-site

# 自動尋找可用端口（推薦）
./test-local.sh

# 或手動指定端口
./test-local.sh 8080

# 其他常用端口
./test-local.sh 3000
./test-local.sh 5000
./test-local.sh 9000
```

腳本會：
- ✅ 檢查所有 i18n 文件是否存在
- ✅ 自動偵測並使用可用端口
- ✅ 顯示樹莓派的 IP 地址（方便從其他設備訪問）
- ✅ 如果端口被佔用，提供警告和解決方案

## 診斷步驟

### 1. 確認文件存在

在您的 repo 根目錄 `/home/yizheng/verifyai-site/` 執行：

```bash
# 檢查文件是否存在
ls -la js/i18n.js
ls -la locales/

# 應該看到：
# js/i18n.js (約 6KB)
# locales/zh-TW.json, en.json, ja.json, ko.json
```

### 2. 確認文件已提交到 Git

```bash
git status
git ls-files | grep -E "(i18n\.js|locales/)"
```

如果文件未被追蹤，需要先 add 和 commit：

```bash
git add js/i18n.js js/smooth-scroll.js locales/*.json
git commit -m "Add i18n files"
git push
```

### 3. 確認當前目錄結構

您的 repo 應該有以下結構：

```
/home/yizheng/verifyai-site/
├── index.html
├── verifyai-complete-final_4.html
├── test-i18n.html
├── js/
│   ├── i18n.js           ← 必須存在
│   └── smooth-scroll.js
└── locales/
    ├── zh-TW.json        ← 必須存在
    ├── en.json           ← 必須存在
    ├── ja.json           ← 必須存在
    └── ko.json           ← 必須存在
```

## 常見問題與解決方案

### 問題 A: 使用 `file://` 協議直接打開 HTML

**症狀**：雙擊 HTML 文件在瀏覽器中打開，看到 404 錯誤

**原因**：某些瀏覽器在 `file://` 協議下限制 JavaScript 載入外部文件

**解決方案**：使用本地 HTTP 服務器

```bash
# 進入您的 repo 目錄
cd /home/yizheng/verifyai-site

# 🌟 推薦: 使用測試腳本（自動選擇可用端口）
./test-local.sh

# 或手動指定端口
./test-local.sh 8080

# 手動啟動服務器的方法：

# 方法 1: 使用 Python (推薦)
python3 -m http.server 8000

# 如果端口 8000 被佔用，使用其他端口
python3 -m http.server 8080
python3 -m http.server 3000
python3 -m http.server 5000

# 方法 2: 使用 Python 2
python -m SimpleHTTPServer 8000

# 方法 3: 使用 Node.js (需要先安裝 http-server)
npx http-server -p 8000

# 方法 4: 使用 PHP
php -S localhost:8000
```

然後在瀏覽器訪問（將端口號改為您使用的端口）：
- `http://localhost:8000/index.html`
- `http://localhost:8080/index.html`
- 或使用樹莓派的 IP：`http://[樹莓派IP]:8080/index.html`

### 問題 B: 從子目錄打開 HTML

**症狀**：如果您不在 repo 根目錄，相對路徑會失效

**解決方案**：確保始終從 repo 根目錄啟動服務器

```bash
# 錯誤的方式
cd /home/yizheng/verifyai-site/some-subdirectory
python3 -m http.server 8000  # ❌ 路徑會錯誤

# 正確的方式
cd /home/yizheng/verifyai-site
python3 -m http.server 8000  # ✅ 正確
```

### 問題 C: 部署到 Web 服務器時路徑錯誤

**症狀**：本地測試正常，但部署後出現 404

**可能原因**：
1. 文件沒有上傳到服務器
2. 服務器上的目錄結構不同
3. 服務器配置問題

**解決方案**：

#### 如果使用 GitHub Pages

確保 `js/` 和 `locales/` 目錄都已推送：

```bash
git add js/ locales/
git commit -m "Add i18n resources"
git push origin main
```

在 GitHub repo 設置中啟用 GitHub Pages，選擇 `main` 分支根目錄。

#### 如果使用其他 Web 服務器

確保上傳完整的目錄結構，包括：
- `js/i18n.js`
- `js/smooth-scroll.js`
- `locales/*.json`

### 問題 D: 端口被佔用（Port Already in Use）

**症狀**：
- 服務器顯示 "Serving HTTP on 0.0.0.0 port 8000..."，但瀏覽器無法連接
- 或出現 "Address already in use" 錯誤

**原因**：端口已被其他服務（如另一個 web 服務器、開發工具等）佔用

**解決方案**：

#### 方案 1: 使用測試腳本自動選擇端口（推薦）

```bash
cd /home/yizheng/verifyai-site
./test-local.sh  # 自動找可用端口
```

#### 方案 2: 手動指定其他端口

```bash
# 嘗試不同的端口
./test-local.sh 8080
./test-local.sh 3000
./test-local.sh 5000
./test-local.sh 9000

# 或手動使用 Python
python3 -m http.server 8080
```

#### 方案 3: 查看並停止佔用端口的進程

```bash
# 查看哪個進程佔用了端口 8000
sudo lsof -i :8000
# 或
sudo netstat -tuln | grep 8000

# 如果需要停止該進程（謹慎使用）
sudo kill -9 [PID]
```

#### 方案 4: 檢查常見的端口佔用原因

在樹莓派上，以下服務可能佔用常用端口：
- **端口 8000**: 可能被其他 Python HTTP 服務器佔用
- **端口 80**: 通常被 Nginx 或 Apache 佔用
- **端口 3000**: 可能被 Node.js 開發服務器佔用
- **端口 8080**: 可能被 Tomcat 或其他 Java 應用佔用

**在樹莓派環境的特殊說明**：

如果您想從其他設備訪問（如手機、電腦），需要：

1. 確認樹莓派的 IP 地址：
```bash
hostname -I
```

2. 確保防火牆允許該端口（如果有啟用）：
```bash
sudo ufw allow 8080/tcp
```

3. 在其他設備的瀏覽器訪問：
```
http://[樹莓派IP]:8080/index.html
```

### 問題 E: 瀏覽器緩存

**症狀**：修復後仍然看到 404 錯誤

**解決方案**：清除瀏覽器緩存

- Chrome/Edge: `Ctrl + Shift + Delete` 或 `Cmd + Shift + Delete`
- Firefox: `Ctrl + Shift + Delete` 或 `Cmd + Shift + Delete`
- 或使用無痕/隱私模式測試

### 問題 F: CORS 錯誤

**症狀**：Console 顯示 CORS 相關錯誤

**解決方案**：使用本地 HTTP 服務器（見問題 A），不要使用 `file://` 協議

## 驗證修復

### 測試步驟

1. **啟動本地服務器**
```bash
cd /home/yizheng/verifyai-site
python3 -m http.server 8000
```

2. **在瀏覽器中打開**
```
http://localhost:8000/index.html
```

3. **打開 DevTools Console** (F12 或右鍵 → 檢查)

4. **檢查錯誤**
   - ✅ 無錯誤 = 修復成功
   - ❌ 仍有錯誤 = 查看具體錯誤訊息

5. **測試語言切換**
   - 點擊導航欄的語言切換按鈕
   - 確認頁面內容正確切換為該語言

### 檢查網絡請求

在 DevTools 的 Network 標籤中：

1. 刷新頁面
2. 篩選 JS 和 JSON 文件
3. 確認以下請求都返回 200 狀態碼：
   - `i18n.js` → 200 ✅
   - `smooth-scroll.js` → 200 ✅
   - `locales/zh-TW.json` → 200 ✅
   - `locales/en.json` → 200 ✅
   - `locales/ja.json` → 200 ✅
   - `locales/ko.json` → 200 ✅

## 如果問題仍未解決

請提供以下信息：

1. **您如何訪問網站？**
   - [ ] 直接雙擊 HTML 文件
   - [ ] 使用本地 HTTP 服務器（哪種？）
   - [ ] 部署到 Web 服務器（哪個？）
   - [ ] 其他方式：____________

2. **瀏覽器和版本**
   - 例如：Chrome 119, Firefox 120, Safari 17

3. **完整的 Console 錯誤訊息**
   - 截圖或複製完整的錯誤訊息

4. **Network 標籤截圖**
   - 顯示失敗的請求和狀態碼

5. **文件結構確認**
```bash
cd /home/yizheng/verifyai-site
find . -name "*.js" -o -name "*.json" | grep -E "(i18n|locales)"
```

## 快速修復腳本

創建一個測試腳本 `test-local.sh`：

```bash
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
echo "🎉 所有文件都存在！"
echo ""
echo "🚀 啟動本地服務器..."
echo "📍 訪問: http://localhost:8000/index.html"
echo ""

python3 -m http.server 8000
```

使用方法：

```bash
cd /home/yizheng/verifyai-site
chmod +x test-local.sh
./test-local.sh
```

## 總結

最常見的原因是直接用 `file://` 協議打開 HTML 文件。

**推薦解決方案：始終使用本地 HTTP 服務器測試**

```bash
cd /home/yizheng/verifyai-site
python3 -m http.server 8000
# 訪問 http://localhost:8000/index.html
```
