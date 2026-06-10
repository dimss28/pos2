<?php

namespace App\Models;

use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Fortify\TwoFactorAuthenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes, TwoFactorAuthenticatable;

    protected $fillable = [
        'name', 'email', 'password', 'phone', 'roles', 'avatar', 'is_active',
        'last_login_at', 'last_login_ip',
    ];

    protected $hidden = [
        'password', 'remember_token', 'two_factor_secret', 'two_factor_recovery_codes',
    ];

    protected $appends = ['avatar_url'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
            'last_login_at' => 'datetime',
        ];
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'kasir_id');
    }

    public function cashSessions()
    {
        return $this->hasMany(CashSession::class);
    }

    public function getAvatarUrlAttribute(): string
    {
        return $this->avatar
            ? asset('storage/avatars/'.$this->avatar)
            : 'https://ui-avatars.com/api/?name='.urlencode($this->name ?? 'User').'&background=3B82F6&color=fff';
    }

    public function role(): ?UserRole
    {
        return $this->roles ? UserRole::tryFrom($this->roles) : null;
    }

    public function isOwner(): bool
    {
        return $this->roles === UserRole::Owner->value;
    }

    public function isAdmin(): bool
    {
        return in_array($this->roles, [UserRole::Owner->value, UserRole::Admin->value]);
    }

    public function isKasir(): bool
    {
        return $this->roles === UserRole::Kasir->value;
    }
}
