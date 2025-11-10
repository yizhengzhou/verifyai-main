# VerifyAI - 多語系網站

這是 VerifyAI 的多語系版本，支援繁體中文（zh-TW）和英文（en）。

## 專案結構

```
verifyai-main/
├── index.html                      # 新的多語系示範頁面
├── verifyai-complete-final_4.html  # 原始完整頁面
├── js/
│   └── i18n.js                     # 國際化核心模組
├── locales/
│   ├── zh-TW.json                  # 繁體中文翻譯檔
│   └── en.json                     # 英文翻譯檔
└── README.md                       # 本檔案
```

## 功能特色

### ✅ 已實現功能

1. **自動語言偵測**
   - 首次訪問時自動偵測瀏覽器語言
   - 支援繁體中文和英文

2. **語言切換器**
   - 導航欄右上角的語言切換按鈕
   - 即時切換，無需重新載入頁面

3. **本地儲存**
   - 使用 localStorage 記住使用者的語言偏好
   - 下次訪問自動套用上次選擇的語言

4. **完整翻譯**
   - 所有頁面文字都支援多語言
   - 包含 meta 標籤（title, description）

## 如何使用

### 在瀏覽器中測試

1. 開啟 `index.html`
2. 點擊右上角的語言切換按鈕（繁體中文 / English）
3. 觀察頁面內容即時切換

### 整合到現有 HTML

要將 i18n 功能整合到 `verifyai-complete-final_4.html`，請按照以下步驟：

#### 步驟 1: 加入 i18n.js 腳本

在 `</head>` 標籤前加入：

```html
<!-- i18n Internationalization Script -->
<script src="./js/i18n.js"></script>
</head>
```

#### 步驟 2: 為需要翻譯的元素加上 data-i18n 屬性

範例：

```html
<!-- 原始 -->
<h1>讓信任有依據</h1>

<!-- 加上 i18n -->
<h1 data-i18n="hero.title">讓信任有依據</h1>
```

```html
<!-- 原始 -->
<a href="#features">功能特色</a>

<!-- 加上 i18n -->
<a href="#features" data-i18n="nav.features">功能特色</a>
```

#### 步驟 3: 加入語言切換器

在導航欄加入語言切換器：

```html
<div class="lang-switcher">
    <a href="#" data-lang="zh-TW" data-i18n="nav.chinese">繁體中文</a>
    <span>/</span>
    <a href="#" data-lang="en" data-i18n="nav.english">English</a>
</div>
```

#### 步驟 4: 加入樣式（可選）

```css
.lang-switcher {
    display: flex;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: var(--neutral-light);
    border-radius: 8px;
}

.lang-switcher a {
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.9rem;
}

.lang-switcher a.active {
    background: var(--verify-green);
    color: white;
}
```

## 語言檔案格式

語言檔案採用 JSON 格式，使用點號分隔的 key 來組織翻譯內容：

```json
{
  "nav": {
    "features": "功能特色",
    "howItWorks": "使用方式"
  },
  "hero": {
    "title": "讓信任有依據",
    "description": "3 秒辨識照片真偽"
  }
}
```

## 新增語言

要新增其他語言（例如日文），請按照以下步驟：

1. 在 `locales/` 目錄下建立新的語言檔案，例如 `ja.json`
2. 複製 `en.json` 的內容並翻譯成日文
3. 在 `js/i18n.js` 中加入新語言到 `supportedLanguages` 陣列：

```javascript
this.supportedLanguages = ['zh-TW', 'en', 'ja'];
```

4. 在語言切換器中加入新選項：

```html
<a href="#" data-lang="ja">日本語</a>
```

## i18n.js API

### 方法

- `i18n.getCurrentLanguage()` - 取得當前語言
- `i18n.changeLanguage(lang)` - 切換語言
- `i18n.t(key)` - 取得翻譯文字
- `i18n.getSupportedLanguages()` - 取得支援的語言列表

### 事件

當語言變更時，會觸發 `languageChanged` 事件：

```javascript
document.addEventListener('languageChanged', (e) => {
  console.log('語言已切換至:', e.detail.language);
});
```

## 技術細節

- **零依賴**: 純 JavaScript 實現，不需要任何外部函式庫
- **輕量級**: i18n.js 僅約 5KB
- **效能優化**: 使用 localStorage 快取語言選擇
- **向後相容**: 對於沒有 `data-i18n` 屬性的元素不影響原有功能

## 瀏覽器支援

- Chrome 60+
- Firefox 55+
- Safari 11+
- Edge 79+

主要使用的現代 API：
- `fetch()` - 載入語言檔案
- `localStorage` - 儲存語言偏好
- `CustomEvent` - 語言變更事件

## 問題排查

### 語言沒有切換？

1. 檢查瀏覽器 Console 是否有錯誤訊息
2. 確認語言檔案路徑正確（`./locales/zh-TW.json`）
3. 確認元素有正確的 `data-i18n` 屬性

### 翻譯顯示 key 而不是文字？

1. 檢查語言檔案中是否有對應的 key
2. 確認 JSON 格式正確（使用 JSONLint 驗證）

### 首次載入語言不正確？

1. 清除瀏覽器的 localStorage
2. 檢查 `navigator.language` 是否為預期值

## 授權

© 2024 VerifyAI. 保留所有權利。
