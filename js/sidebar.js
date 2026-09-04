function renderSidebar(activeMenuId, currentUser = null, onLogout = null) {
    const menuItems = [
        { id: 'dashboard', label: 'Dashboard Utama', icon: '📊', path: 'index.html' },
        { id: 'stock', label: 'Manajemen Stok', icon: '📦', path: 'stock.html' },
        { id: 'reports', label: 'Laporan Penjualan', icon: '📈', path: 'report.html' },
    ];

    const currentFilename = window.location.pathname.split('/').pop() || 'index.html';

    const navContainer = document.getElementById('sidebarNav');
    if (navContainer) {
        navContainer.innerHTML = menuItems.map((item) => {
            const isActive = activeMenuId === item.id || currentFilename === item.path;
            return `
                <a href="${item.path}" 
                   class="flex items-center gap-3 px-4 py-3 rounded-xl font-bold text-sm transition ${
                       isActive 
                       ? 'bg-zinc-800 text-white' 
                       : 'text-zinc-400 hover:bg-zinc-900 hover:text-white font-semibold'
                   }">
                    <span>${item.icon}</span> ${item.label}
                </a>
            `;
        }).join('');
    }

    if (currentUser) {
        const nameEl = document.getElementById('sidebarUserName');
        const roleEl = document.getElementById('sidebarUserRole');
        if (nameEl) nameEl.innerText = currentUser.name || 'Admin';
        if (roleEl) roleEl.innerText = currentUser.role || 'Super Admin';
    }

    const logoutBtn = document.getElementById('sidebarLogoutBtn');
    if (logoutBtn && typeof onLogout === 'function') {
        logoutBtn.replaceWith(logoutBtn.cloneNode(true));
        document.getElementById('sidebarLogoutBtn').addEventListener('click', onLogout);
    }
}