import { ADMIN_MENU_ITEMS, MenuItem } from '../constants/navigation.ts';

interface UserProfile {
    name?: string;
    role?: string;
}

export function renderSidebar(
    activeMenuId: string, 
    user?: UserProfile, 
    onLogout?: () => void, 
    elementId: string = 'sidebar-container'
): void {
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

    const userName = user?.name || 'Admin';
    const userRole = user?.role || 'Super Admin';

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
                    <p class="user-name">${userName}</p>
                    <p class="user-role">${userRole}</p>
                </div>
                <button id="btn-logout" class="btn-logout">Keluar</button>
            </div>
        </aside>
    `;

    if (onLogout) {
        const logoutBtn = document.getElementById('btn-logout');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', onLogout);
        }
    }
}