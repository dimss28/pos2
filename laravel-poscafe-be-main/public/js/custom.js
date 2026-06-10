document.addEventListener('click', function (e) {
    // Sidebar toggle (mobile)
    if (e.target.closest('.hamburger')) {
        document.querySelector('.main-sidebar')?.classList.toggle('open');
        return;
    }

    // User dropdown toggle
    const userBtn = e.target.closest('.user-btn');
    if (userBtn) {
        e.preventDefault();
        userBtn.parentElement.querySelector('.dropdown-menu')?.classList.toggle('show');
        return;
    } else {
        document.querySelectorAll('.user-dropdown .dropdown-menu.show').forEach(el => el.classList.remove('show'));
    }

    // Delete confirm via SweetAlert2
    const delBtn = e.target.closest('.confirm-delete');
    if (delBtn && window.Swal) {
        e.preventDefault();
        const url = delBtn.dataset.action;
        const csrf = document.querySelector('meta[name="csrf-token"]')?.content;
        Swal.fire({
            title: 'Yakin hapus?',
            text: 'Aksi tidak bisa dibatalkan.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#EF4444',
            confirmButtonText: 'Ya, hapus',
            cancelButtonText: 'Batal',
        }).then(r => {
            if (!r.isConfirmed) return;
            const f = document.createElement('form');
            f.method = 'POST';
            f.action = url;
            f.innerHTML = `<input type="hidden" name="_token" value="${csrf}"><input type="hidden" name="_method" value="DELETE">`;
            document.body.appendChild(f);
            f.submit();
        });
    }
});

window.AppToast = (type, msg) => window.Swal?.fire({
    toast: true, position: 'top-end', icon: type, title: msg,
    timer: 3500, showConfirmButton: false,
});

function togglePwd(id) {
    const el = document.getElementById(id);
    if (el) el.type = el.type === 'password' ? 'text' : 'password';
}
window.togglePwd = togglePwd;
