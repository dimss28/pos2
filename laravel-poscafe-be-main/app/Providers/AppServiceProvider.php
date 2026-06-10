<?php

namespace App\Providers;

use App\Listeners\UpdateLastLoginAt;
use Carbon\Carbon;
use Illuminate\Auth\Events\Login;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        Paginator::useBootstrapFive();
        Carbon::setLocale(config('app.locale', 'id'));
        @setlocale(LC_TIME, 'id_ID.UTF-8', 'id_ID', 'id');

        Event::listen(Login::class, UpdateLastLoginAt::class);
    }
}
