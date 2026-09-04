function renderSidebar(activeMenuId, elementId = 'sidebar-container', currentUser = null, onLogout = null) {
    const container = document.getElementById(elementId);
    if (!container) return;

    const menuItems = [
        { id: 'dashboard', label: 'Dashboard Utama', icon: '📊', path: 'index.html' },
        { id: 'stock', label: 'Manajemen Stok', icon: '📦', path: 'stock.html' },
        { id: 'reports', label: 'Laporan Penjualan', icon: '📈', path: 'report.html' },
    ];

    const currentFilename = window.location.pathname.split('/').pop() || 'index.html';

    const menuHtml = menuItems.map((item) => {
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

    const userName = currentUser?.name || 'Admin';
    const userRole = currentUser?.role || 'Super Admin';

    container.innerHTML = `
        <aside class="w-64 bg-black text-white flex flex-col justify-between p-5 h-screen shrink-0">
            <div>
                <div class="mb-8 flex items-center gap-3">
                    <div class="w-10 h-10 bg-white rounded-xl flex items-center justify-center font-extrabold text-black text-xl">
                        KA
                    </div>
                    <div>
                        <h1 class="font-extrabold text-lg tracking-wider">KOPI AJOE</h1>
                        <p class="text-xs text-zinc-400">Admin Control Panel</p>
                    </div>
                </div>

                <nav class="space-y-2">
                    ${menuHtml}
                </nav>
            </div>

            <div class="border-t border-zinc-800 pt-4 flex justify-between items-center">
                <div>
                    <p class="text-xs font-bold text-white">${userName}</p>
                    <p class="text-[10px] text-zinc-500">${userRole}</p>
                </div>
                <button id="sidebarLogoutBtn" class="text-xs text-red-400 font-bold hover:underline">Keluar</button>
            </div>
        </aside>
    `;

    const logoutBtn = document.getElementById('sidebarLogoutBtn');
    if (logoutBtn && typeof onLogout === 'function') {
        logoutBtn.addEventListener('click', onLogout);
    }
}