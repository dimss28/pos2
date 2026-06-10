<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CashSessionController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\PromoController;
use App\Http\Controllers\Api\RefundController;
use App\Http\Controllers\Api\ReportController;
use Illuminate\Support\Facades\Route;

Route::post('login', [AuthController::class, 'login'])->middleware('throttle:5,1');

Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('me', [AuthController::class, 'me']);
    Route::get('user', [AuthController::class, 'me']);
    Route::delete('account', [AuthController::class, 'deleteAccount']);

    // Products
    Route::apiResource('products', ProductController::class)->only(['index', 'show', 'store', 'update']);
    Route::post('products/{product}', [ProductController::class, 'update'])->whereNumber('product');

    // Orders
    Route::apiResource('orders', OrderController::class)->only(['index', 'show', 'store']);
    Route::get('orders/kasir/{kasir_id}', [OrderController::class, 'getByKasirId']);
    Route::post('orders/{order}/refund', [RefundController::class, 'store'])->whereNumber('order');

    // Categories (unnamed routes — avoid clash with web `categories.index`)
    Route::get('list-categories', [CategoryController::class, 'index']);
    Route::get('categories', [CategoryController::class, 'index']);

    // Reports
    Route::prefix('reports')->group(function () {
        Route::get('summary', [ReportController::class, 'summary']);
        Route::get('product-sales', [ReportController::class, 'productSales']);
        Route::get('close-cashier', [ReportController::class, 'closeCashier']);
    });

    // Cash Sessions
    Route::prefix('cash-sessions')->group(function () {
        Route::get('/', [CashSessionController::class, 'index']);
        Route::get('current', [CashSessionController::class, 'current']);
        Route::post('open', [CashSessionController::class, 'open']);
        Route::get('{id}', [CashSessionController::class, 'show'])->whereNumber('id');
        Route::get('{id}/summary', [CashSessionController::class, 'summary'])->whereNumber('id');
        Route::post('{id}/close', [CashSessionController::class, 'close'])->whereNumber('id');
    });

    // Table orders (guest QR flow — kasir/admin inbox)
    Route::prefix('table-orders')->group(function () {
        Route::get('/', [\App\Http\Controllers\Api\TableOrderController::class, 'index']);
        Route::get('{order}', [\App\Http\Controllers\Api\TableOrderController::class, 'show'])->whereNumber('order');
        Route::post('{order}/confirm', [\App\Http\Controllers\Api\TableOrderController::class, 'confirm'])->whereNumber('order');
        Route::post('{order}/reject', [\App\Http\Controllers\Api\TableOrderController::class, 'reject'])->whereNumber('order');
        Route::post('{order}/status', [\App\Http\Controllers\Api\TableOrderController::class, 'updateStatus'])->whereNumber('order');
    });

    // Promos
    Route::prefix('promos')->group(function () {
        Route::get('/', [PromoController::class, 'index']);
        Route::post('/', [PromoController::class, 'store']);
        Route::post('apply', [PromoController::class, 'apply']);
        Route::get('{promo}', [PromoController::class, 'show']);
        Route::put('{promo}', [PromoController::class, 'update']);
        Route::post('{promo}/toggle', [PromoController::class, 'toggle']);
        Route::delete('{promo}', [PromoController::class, 'destroy']);
    });
});
