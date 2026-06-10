<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    if (auth()->check()) {
        return redirect()->route('home');
    }

    return view('pages.auth.login');
});

Route::get('m/{token}', [\App\Http\Controllers\GuestOrderController::class, 'show'])->name('guest.order');
Route::post('m/{token}/checkout', [\App\Http\Controllers\GuestOrderController::class, 'checkout'])->name('guest.checkout');
Route::get('m/{token}/orders/{order}/status', [\App\Http\Controllers\GuestOrderController::class, 'paymentStatus'])
    ->name('guest.order.status');

Route::middleware(['auth', 'cache.headers:no_store;no_cache;must_revalidate;max_age=0'])->group(function () {
    Route::get('home', [\App\Http\Controllers\DashboardController::class, 'index'])->name('home');
    Route::get('showcase', fn () => view('pages._component-showcase'))->name('showcase');

    Route::resource('categories', \App\Http\Controllers\CategoryController::class);

    Route::delete('product/bulk', [\App\Http\Controllers\ProductController::class, 'bulkDestroy'])->name('product.bulk-destroy');
    Route::resource('product', \App\Http\Controllers\ProductController::class);

    Route::resource('user', \App\Http\Controllers\UserController::class);

    Route::post('promo/{promo}/toggle', [\App\Http\Controllers\PromoController::class, 'toggle'])->name('promo.toggle');
    Route::resource('promo', \App\Http\Controllers\PromoController::class)->except(['show']);

    Route::get('dining-table/qr-download-all', [\App\Http\Controllers\DiningTableController::class, 'downloadAllQr'])
        ->name('dining-table.qr-all');
    Route::post('dining-table/{dining_table}/regenerate-token', [\App\Http\Controllers\DiningTableController::class, 'regenerateToken'])
        ->name('dining-table.regenerate');
    Route::get('dining-table/{dining_table}/qr', [\App\Http\Controllers\DiningTableController::class, 'downloadQr'])
        ->name('dining-table.qr');
    Route::resource('dining-table', \App\Http\Controllers\DiningTableController::class)->except(['show']);

    Route::get('store-settings', [\App\Http\Controllers\StoreSettingController::class, 'edit'])->name('store-settings.edit');
    Route::put('store-settings', [\App\Http\Controllers\StoreSettingController::class, 'update'])->name('store-settings.update');

    Route::get('table-orders', [\App\Http\Controllers\TableOrderController::class, 'index'])->name('table-order.index');
    Route::get('table-orders/{order}', [\App\Http\Controllers\TableOrderController::class, 'show'])->name('table-order.show');
    Route::post('table-orders/{order}/confirm', [\App\Http\Controllers\TableOrderController::class, 'confirm'])->name('table-order.confirm');
    Route::post('table-orders/{order}/reject', [\App\Http\Controllers\TableOrderController::class, 'reject'])->name('table-order.reject');
    Route::post('table-orders/{order}/status', [\App\Http\Controllers\TableOrderController::class, 'updateStatus'])->name('table-order.status');

    Route::get('order/export', [\App\Http\Controllers\OrderController::class, 'export'])->name('order.export');
    Route::get('order/{order}/receipt', [\App\Http\Controllers\OrderController::class, 'receipt'])->name('order.receipt');
    Route::get('order/{order}/invoice-pdf', [\App\Http\Controllers\OrderController::class, 'invoicePdf'])->name('order.invoice-pdf');
    Route::resource('order', \App\Http\Controllers\OrderController::class)->only(['index', 'show', 'destroy']);

    Route::prefix('cash-sessions')->name('cash-session.')->group(function () {
        Route::get('/', [\App\Http\Controllers\CashSessionController::class, 'index'])->name('index');
        Route::post('/open', [\App\Http\Controllers\CashSessionController::class, 'open'])->name('open');
        Route::get('/{cashSession}', [\App\Http\Controllers\CashSessionController::class, 'show'])->name('show');
        Route::post('/{cashSession}/close', [\App\Http\Controllers\CashSessionController::class, 'close'])->name('close');
        Route::post('/{cashSession}/force-close', [\App\Http\Controllers\CashSessionController::class, 'forceClose'])->name('force-close');
    });

    Route::prefix('reports')->name('reports.')->middleware('can:view-reports')->group(function () {
        Route::get('/', [\App\Http\Controllers\ReportController::class, 'index'])->name('index');
        Route::get('/summary', [\App\Http\Controllers\ReportController::class, 'summary'])->name('summary');
        Route::get('/product-sales', [\App\Http\Controllers\ReportController::class, 'productSales'])->name('product-sales');
        Route::get('/close-cashier', [\App\Http\Controllers\ReportController::class, 'closeCashier'])->name('close-cashier');
        Route::get('/promo-usage', [\App\Http\Controllers\ReportController::class, 'promoUsage'])->name('promo-usage');
        Route::get('/sales-analytics', [\App\Http\Controllers\ReportController::class, 'salesAnalytics'])->name('sales-analytics');
        Route::get('/inventory', [\App\Http\Controllers\ReportController::class, 'inventory'])->name('inventory');
        Route::get('/export/{type}', [\App\Http\Controllers\ReportController::class, 'export'])->name('export');
    });

    Route::prefix('profile')->name('profile.')->group(function () {
        Route::get('/', [\App\Http\Controllers\ProfileController::class, 'show'])->name('show');
        Route::put('/', [\App\Http\Controllers\ProfileController::class, 'update'])->name('update');
        Route::put('/password', [\App\Http\Controllers\ProfileController::class, 'updatePassword'])->name('password');
        Route::delete('/', [\App\Http\Controllers\ProfileController::class, 'destroy'])->name('destroy');
    });
});
