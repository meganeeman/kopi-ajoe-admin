export interface MenuItem {
    id: string;
    label: string;
    icon: string;
    path: string;
}

export const ADMIN_MENU_ITEMS: MenuItem[] = [
    {
        id: 'dashboard',
        label: 'Dashboard Utama',
        icon: '📊',
        path: 'index.html',
    },
    {
        id: 'stock',
        label: 'Manajemen Stok',
        icon: '📦',
        path: 'stock.html',
    },
    {
        id: 'reports',
        label: 'Laporan Penjualan',
        icon: '📈',
        path: 'report.html',
    },
];