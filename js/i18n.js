/**
 * VerifyAI Internationalization (i18n) Module
 * Handles multi-language support for the application
 */

class I18n {
    constructor() {
        this.currentLang = 'zh-TW'; // Default language
        this.translations = {};
        this.supportedLanguages = ['zh-TW', 'en'];
    }

    /**
     * Initialize i18n system
     */
    async init() {
        // Check for saved language preference
        const savedLang = localStorage.getItem('preferredLanguage');
        if (savedLang && this.supportedLanguages.includes(savedLang)) {
            this.currentLang = savedLang;
        } else {
            // Detect browser language
            const browserLang = navigator.language || navigator.userLanguage;
            if (browserLang.startsWith('zh')) {
                this.currentLang = 'zh-TW';
            } else {
                this.currentLang = 'en';
            }
        }

        // Load translation files
        await this.loadTranslations();

        // Apply translations to the page
        this.applyTranslations();

        // Setup language switcher
        this.setupLanguageSwitcher();

        // Update HTML lang attribute
        document.documentElement.lang = this.currentLang;
    }

    /**
     * Load translation files
     */
    async loadTranslations() {
        try {
            const response = await fetch(`./locales/${this.currentLang}.json`);
            if (!response.ok) {
                throw new Error(`Failed to load translations for ${this.currentLang}`);
            }
            this.translations = await response.json();
        } catch (error) {
            console.error('Error loading translations:', error);
            // Fallback to default language if loading fails
            if (this.currentLang !== 'zh-TW') {
                this.currentLang = 'zh-TW';
                const fallbackResponse = await fetch('./locales/zh-TW.json');
                this.translations = await fallbackResponse.json();
            }
        }
    }

    /**
     * Get translation for a key using dot notation
     * @param {string} key - Translation key (e.g., 'nav.features')
     * @returns {string} Translated text
     */
    t(key) {
        const keys = key.split('.');
        let value = this.translations;

        for (const k of keys) {
            if (value && typeof value === 'object' && k in value) {
                value = value[k];
            } else {
                console.warn(`Translation key not found: ${key}`);
                return key;
            }
        }

        return value;
    }

    /**
     * Apply translations to all elements with data-i18n attribute
     */
    applyTranslations() {
        // Update meta tags
        document.title = this.t('meta.title');
        const metaDescription = document.querySelector('meta[name="description"]');
        if (metaDescription) {
            metaDescription.content = this.t('meta.description');
        }

        // Update all elements with data-i18n attribute
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            const translation = this.t(key);

            // Check if element has data-i18n-attr to specify which attribute to translate
            const attr = element.getAttribute('data-i18n-attr');
            if (attr) {
                element.setAttribute(attr, translation);
            } else {
                // Default: update innerHTML
                element.innerHTML = translation;
            }
        });

        // Update all elements with data-i18n-placeholder attribute
        document.querySelectorAll('[data-i18n-placeholder]').forEach(element => {
            const key = element.getAttribute('data-i18n-placeholder');
            element.placeholder = this.t(key);
        });
    }

    /**
     * Change language
     * @param {string} lang - Language code (e.g., 'en', 'zh-TW')
     */
    async changeLanguage(lang) {
        if (!this.supportedLanguages.includes(lang)) {
            console.error(`Unsupported language: ${lang}`);
            return;
        }

        this.currentLang = lang;
        localStorage.setItem('preferredLanguage', lang);
        document.documentElement.lang = lang;

        await this.loadTranslations();
        this.applyTranslations();

        // Trigger custom event for language change
        const event = new CustomEvent('languageChanged', { detail: { language: lang } });
        document.dispatchEvent(event);
    }

    /**
     * Setup language switcher UI
     */
    setupLanguageSwitcher() {
        // Find all language switch buttons
        const langButtons = document.querySelectorAll('[data-lang]');

        langButtons.forEach(button => {
            button.addEventListener('click', (e) => {
                e.preventDefault();
                const targetLang = button.getAttribute('data-lang');
                this.changeLanguage(targetLang);

                // Update active state
                langButtons.forEach(btn => btn.classList.remove('active'));
                button.classList.add('active');
            });

            // Set initial active state
            if (button.getAttribute('data-lang') === this.currentLang) {
                button.classList.add('active');
            }
        });
    }

    /**
     * Get current language
     * @returns {string} Current language code
     */
    getCurrentLanguage() {
        return this.currentLang;
    }

    /**
     * Get supported languages
     * @returns {Array} Array of supported language codes
     */
    getSupportedLanguages() {
        return this.supportedLanguages;
    }
}

// Create global i18n instance
const i18n = new I18n();

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => i18n.init());
} else {
    i18n.init();
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = i18n;
}
