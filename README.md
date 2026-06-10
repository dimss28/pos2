# POS

Monorepo aplikasi Point of Sale.

## Isi repo

| Folder | Keterangan |
|--------|------------|
| `laravel-poscafe-be-main/` | Backend API + admin web (Laravel) |
| `flutter_pos_app-newjilid3/` | Aplikasi kasir mobile (Flutter) |
| `fic11jilid3-db.sql` | Dump database contoh |

## Setup cepat (lokal)

### Backend

```bash
cd laravel-poscafe-be-main
composer install --ignore-platform-reqs   # jika PHP < 8.3
cp .env.example .env
php artisan key:generate
# atur DB di .env, lalu:
php artisan migrate --seed
php artisan storage:link
php artisan serve
```

### Flutter

```bash
cd flutter_pos_app-newjilid3
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000
```

## Deploy via Git (server)

```bash
git clone https://github.com/dimss28/pos.git
cd pos/laravel-poscafe-be-main
composer install --no-dev --optimize-autoloader
cp .env.example .env
# edit .env production, lalu:
php artisan key:generate
php artisan migrate --force
php artisan storage:link
php artisan config:cache
```

Build APK:

```bash
cd ../flutter_pos_app-newjilid3
flutter build apk --release --dart-define=BASE_URL=https://api.domain-anda.com
```
