<?php

namespace App\Enums;

enum UserRole: string
{
    case Owner = 'owner';
    case Admin = 'admin';
    case Kasir = 'kasir';

    public function label(): string
    {
        return match ($this) {
            self::Owner => 'Pemilik',
            self::Admin => 'Admin',
            self::Kasir => 'Kasir',
        };
    }

    public function badgeClass(): string
    {
        return match ($this) {
            self::Owner => 'danger',
            self::Admin => 'primary',
            self::Kasir => 'info',
        };
    }

    public static function options(): array
    {
        return [
            self::Owner->value => self::Owner->label(),
            self::Admin->value => self::Admin->label(),
            self::Kasir->value => self::Kasir->label(),
        ];
    }
}
