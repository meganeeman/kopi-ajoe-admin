const SUPABASE_URL = 'https://qtcrlxxzaranmvyohsdb.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0Y3JseHh6YXJhbm12eW9oc2RiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzMjc4NDksImV4cCI6MjEwMTkwMzg0OX0.dxahqrteBVVfNfK6Snz_ocbgfpgYY_l6_mv0RjKuLB0';

const supabaseAdmin = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

const audioContext = new (window.AudioContext || window.webkitAudioContext)();

function playNotificationBeep() {
    try {
        const osc = audioContext.createOscillator();
        const gain = audioContext.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(587.33, audioContext.currentTime);
        gain.gain.setValueAtTime(0.1, audioContext.currentTime);
        osc.connect(gain);
        gain.connect(audioContext.destination);
        osc.start();
        osc.stop(audioContext.currentTime + 0.3);
    } catch (e) {
        console.log('Audio autoplay blocked', e);
    }
}

function showToastNotification(title, message) {
    playNotificationBeep();

    const toast = document.createElement('div');
    toast.className = 'toast-notification';
    toast.innerHTML = `
        <div style="font-size: 20px;">📦</div>
        <div>
            <h4 style="font-weight: 800; font-size: 14px; margin: 0;">${title}</h4>
            <p style="font-size: 12px; color: #a1a1aa; margin: 2px 0 0 0;">${message}</p>
        </div>
    `;

    document.body.appendChild(toast);

    setTimeout(() => {
        toast.remove();
    }, 5000);
}

function listenToRealtimeRequests() {
    supabaseAdmin
        .channel('public:stock_requests')
        .on(
            'postgres_changes',
            { event: 'INSERT', schema: 'public', table: 'stock_requests' },
            (payload) => {
                const newReq = payload.new;
                showToastNotification(
                    'Request Stok Baru!',
                    `Permintaan ${newReq.quantity} cup ${newReq.product_name} masuk.`
                );
                
                if (typeof loadPendingRequests === 'function') {
                    loadPendingRequests();
                }
            }
        )
        .subscribe();
}

document.addEventListener('DOMContentLoaded', () => {
    listenToRealtimeRequests();
});