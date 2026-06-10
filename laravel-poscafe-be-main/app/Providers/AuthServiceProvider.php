<?php

namespace App\Providers;

use App\Models\CashSession;
use App\Models\Category;
use App\Models\DiningTable;
use App\Models\Order;
use App\Models\Product;
use App\Models\Promo;
use App\Models\User;
use App\Policies\CashSessionPolicy;
use App\Policies\CategoryPolicy;
use App\Policies\DiningTablePolicy;
use App\Policies\OrderPolicy;
use App\Policies\ProductPolicy;
use App\Policies\PromoPolicy;
use App\Policies\UserPolicy;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        Gate::policy(Product::class, ProductPolicy::class);
        Gate::policy(Category::class, CategoryPolicy::class);
        Gate::policy(Order::class, OrderPolicy::class);
        Gate::policy(User::class, UserPolicy::class);
        Gate::policy(CashSession::class, CashSessionPolicy::class);
        Gate::policy(Promo::class, PromoPolicy::class);
        Gate::policy(DiningTable::class, DiningTablePolicy::class);

        Gate::define('view-reports', fn (User $user) => $user->isAdmin());
    }
}
