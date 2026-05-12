// 语言切换器组件
// 在HTML中调用: LanguageSwitcher.init()

class LanguageSwitcher {
    static init() {
        // 等待i18n初始化完成
        setTimeout(() => {
            this.createSwitcher();
            this.updateActiveLanguage();
            
            // 监听语言切换事件
            window.addEventListener('languageChanged', () => {
                this.updateActiveLanguage();
            });
        }, 500);
    }

    static createSwitcher() {
        // 检查是否已存在
        if (document.getElementById('language-switcher')) return;

        // 创建语言切换器容器
        const container = document.createElement('div');
        container.id = 'language-switcher';
        container.className = 'dropdown';
        container.style.cssText = `
            position: fixed;
            top: 10px;
            right: 10px;
            z-index: 9999;
        `;

        // 创建触发按钮
        const trigger = document.createElement('button');
        trigger.className = 'btn btn-outline-secondary dropdown-toggle';
        trigger.type = 'button';
        trigger.setAttribute('data-bs-toggle', 'dropdown');
        trigger.innerHTML = `
            <i class="bi bi-translate"></i>
            <span id="current-lang-label">中文</span>
        `;

        // 创建下拉菜单
        const menu = document.createElement('ul');
        menu.className = 'dropdown-menu';
        menu.innerHTML = `
            <li>
                <a class="dropdown-item" href="#" data-lang="zh-CN">
                    <i class="bi bi-check-circle" id="check-zh-CN" style="display:none;"></i>
                    中文
                </a>
            </li>
            <li>
                <a class="dropdown-item" href="#" data-lang="en">
                    <i class="bi bi-check-circle" id="check-en" style="display:none;"></i>
                    English
                </a>
            </li>
        `;

        container.appendChild(trigger);
        container.appendChild(menu);
        document.body.appendChild(container);

        // 绑定事件
        menu.querySelectorAll('.dropdown-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const lang = e.currentTarget.getAttribute('data-lang');
                window.i18n.setLanguage(lang);
            });
        });
    }

    static updateActiveLanguage() {
        const currentLang = window.i18n.getLanguage();
        
        // 更新显示
        const label = document.getElementById('current-lang-label');
        if (label) {
            label.textContent = currentLang === 'zh-CN' ? '中文' : 'English';
        }

        // 更新勾选标记
        document.querySelectorAll('[id^="check-"]').forEach(el => {
            el.style.display = 'none';
        });
        
        const check = document.getElementById(`check-${currentLang}`);
        if (check) {
            check.style.display = 'inline';
        }
    }
}

// 导出到全局
window.LanguageSwitcher = LanguageSwitcher;

export default LanguageSwitcher;
