import { ADMIN_MENU_ITEMS, MenuItem } from '../constants/navigation.ts';

export function renderSidebar(activeMenuId: string, elementId: string = 'sidebar-container'): void {
    const container = document.getElementById(elementId);
    if (!container) return;

    const currentFilename = window.location.pathname.split('/').pop() || 'index.html';

    const menuHtml = ADMIN_MENU_ITEMS.map((item: MenuItem) => {
        const isActive = activeMenuId === item.id || currentFilename === item.path;
        return `
            <a href="${item.path}" class="menu-item ${isActive ? 'active' : ''}">
                <span class="menu-icon">${item.icon}</span>
                <span class="menu-label">${item.label}</span>
            </a>
        `;
    }).join('');

    container.innerHTML = `
        <aside class="sidebar-wrapper">
            <div class="sidebar-brand">
                <div class="logo-badge">KA</div>
                <div>
                    <h1 class="brand-title">KOPI AJOE</h1>
                    <p class="brand-subtitle">Admin Control Panel</p>
                </div>
            </div>

            <nav class="sidebar-nav">
                ${menuHtml}
            </nav>

            <div class="sidebar-footer">
                <div>
                    <p class="user-name">Akbar Permana Erianto</p>
                    <p class="user-role">Super Admin</p>
                </div>
                <button id="btn-logout" class="btn-logout">Keluar</button>
            </div>
        </aside>
    `;
}