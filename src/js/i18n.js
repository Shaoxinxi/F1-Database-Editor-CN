// i18n 国际化配置
// 用于F1 Database Editor中文汉化

class I18n {
    constructor() {
        this.currentLang = localStorage.getItem('language') || 'zh-CN';
        this.translations = {};
        this.isInitialized = false;
    }

    // 初始化i18n
    async init() {
        if (this.isInitialized) return;
        
        try {
            // 加载中文翻译
            const zhResponse = await fetch('locales/zh-CN/translation.json');
            this.translations['zh-CN'] = await zhResponse.json();
            
            // 加载英文翻译
            const enResponse = await fetch('locales/en/translation.json');
            this.translations['en'] = await enResponse.json();
            
            this.isInitialized = true;
            console.log('[i18n] 初始化完成，当前语言:', this.currentLang);
        } catch (error) {
            console.error('[i18n] 加载翻译文件失败:', error);
        }
    }

    // 翻译文本
    t(key) {
        const keys = key.split('.');
        let value = this.translations[this.currentLang];
        
        for (const k of keys) {
            if (value && value[k] !== undefined) {
                value = value[k];
            } else {
                // 如果找不到翻译，返回键名
                console.warn(`[i18n] 未找到翻译: ${key}`);
                return key;
            }
        }
        
        return value;
    }

    // 切换语言
    setLanguage(lang) {
        this.currentLang = lang;
        localStorage.setItem('language', lang);
        document.documentElement.lang = lang;
        
        // 触发语言切换事件
        window.dispatchEvent(new CustomEvent('languageChanged', { detail: { lang } }));
        
        // 重新渲染页面
        this.updatePageContent();
        
        console.log('[i18n] 语言已切换为:', lang);
    }

    // 获取当前语言
    getLanguage() {
        return this.currentLang;
    }

    // 更新页面内容
    updatePageContent() {
        // 更新所有带data-i18n属性的元素
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            const translated = this.t(key);
            
            if (element.tagName === 'INPUT' || element.tagName === 'BUTTON') {
                element.textContent = translated;
            } else if (element.hasAttribute('placeholder')) {
                element.setAttribute('placeholder', translated);
            } else {
                element.textContent = translated;
            }
        });
        
        // 更新带data-i18n-placeholder的元素
        document.querySelectorAll('[data-i18n-placeholder]').forEach(element => {
            const key = element.getAttribute('data-i18n-placeholder');
            element.setAttribute('placeholder', this.t(key));
        });
        
        // 更新带data-i18n-title的元素
        document.querySelectorAll('[data-i18n-title]').forEach(element => {
            const key = element.getAttribute('data-i18n-title');
            element.setAttribute('title', this.t(key));
        });
    }
}

// 创建全局i18n实例
const i18n = new I18n();

// 导出到全局
window.i18n = i18n;

export default i18n;
