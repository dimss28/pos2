<?php

namespace App\Policies;

use App\Models\DiningTable;
use App\Models\User;

class DiningTablePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isAdmin();
    }

    public function view(User $user, DiningTable $table): bool
    {
        return $user->isAdmin();
    }

    public function create(User $user): bool
    {
        return $user->isAdmin();
    }

    public function update(User $user, DiningTable $table): bool
    {
        return $user->isAdmin();
    }

    public function delete(User $user, DiningTable $table): bool
    {
        return $user->isAdmin();
    }
}
