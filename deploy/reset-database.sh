#!/bin/bash
# Reset database POS — HAPUS SEMUA data lama, isi ulang dari seeder.
# Jalankan di server setelah git pull. BACKUP dulu jika masih perlu data lama.

set -e

APP_DIR="${1:-$HOME/pos/laravel-poscafe-be-main}"

cd "$APP_DIR"

echo "=== PERINGATAN: Semua order, user, produk lama akan DIHAPUS ==="
read -r -p "Ketik YES untuk lanjut: " confirm
if [ "$confirm" != "YES" ]; then
  echo "Dibatalkan."
  exit 1
fi

php artisan down || true
php artisan migrate:fresh --seed --force
php artisan storage:link 2>/dev/null || true
mkdir -p storage/app/public/payment-proofs
chmod -R 775 storage bootstrap/cache
php artisan config:clear
php artisan route:clear
php artisan cache:clear
php artisan up

echo ""
echo "Selesai. Login:"
echo "  Owner : owner@cakslamet.com / 12345678"
echo "  Admin : admin@cakslamet.com / 12345678"
echo "  Kasir : kasir@cakslamet.com / 12345678"
echo ""
echo "Toko  : BEBEK GORENG CaK SLAMET"
echo "Atur rekening transfer & Midtrans di Pengaturan Toko (web admin)."
