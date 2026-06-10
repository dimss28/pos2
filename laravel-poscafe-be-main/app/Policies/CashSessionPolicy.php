<?php

namespace App\Policies;

use App\Models\CashSession;
use App\Models\User;

class CashSessionPolicy
{
    public function viewAny(User $user): bool { return true; }
    public function view(User $user, CashSession $session): bool
    {
        return $user->isAdmin() || $session->user_id === $user->id;
    }
    public function forceClose(User $user, CashSession $session): bool
    {
        return $user->isAdmin() && is_null($session->closed_at);
    }
}
