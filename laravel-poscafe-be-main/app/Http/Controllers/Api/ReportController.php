<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\Order;
use App\Models\OrderItem;
use Carbon\Carbon;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function summary(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        $base = Order::whereBetween('transaction_time', [$from, $to])
                     ->where('status', Order::STATUS_PAID);

        $stats = [
            'total_revenue' => (int) (clone $base)->sum('total_price'),
            'total_orders' => (clone $base)->count(),
            'total_items' => (int) (clone $base)->sum('total_item'),
            'avg_per_order' => (int) (clone $base)->avg('total_price'),
        ];

        $daily = (clone $base)
            ->selectRaw('DATE(transaction_time) date, SUM(total_price) total, COUNT(*) count')
            ->groupBy('date')->orderBy('date')->get();

        return ApiResponse::success(compact('stats', 'daily'));
    }

    public function productSales(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        $rows = OrderItem::join('orders', 'order_items.order_id', '=', 'orders.id')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->leftJoin('categories', 'products.category_id', '=', 'categories.id')
            ->whereBetween('orders.transaction_time', [$from, $to])
            ->where('orders.status', Order::STATUS_PAID)
            ->selectRaw('products.id, products.name product_name, COALESCE(categories.name,"Lainnya") category_name,
                         SUM(order_items.quantity) qty_sold, SUM(order_items.total_price) revenue')
            ->groupBy('products.id', 'products.name', 'categories.name')
            ->orderByDesc('revenue')->get();

        return ApiResponse::success($rows);
    }

    public function closeCashier(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        $rows = Order::join('users', 'orders.kasir_id', '=', 'users.id')
            ->whereBetween('transaction_time', [$from, $to])
            ->where('status', Order::STATUS_PAID)
            ->selectRaw('users.name kasir_name, payment_method, COUNT(*) order_count, SUM(total_price) revenue')
            ->groupBy('users.id', 'users.name', 'payment_method')
            ->orderBy('users.name')->orderBy('payment_method')->get();

        return ApiResponse::success($rows);
    }

    private function resolveRange(Request $request): array
    {
        $from = $request->get('from') ? Carbon::parse($request->get('from'))->startOfDay() : today()->startOfDay();
        $to = $request->get('to') ? Carbon::parse($request->get('to'))->endOfDay() : now();

        return [$from, $to];
    }
}
