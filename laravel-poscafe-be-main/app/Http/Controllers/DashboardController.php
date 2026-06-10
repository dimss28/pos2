<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        $today = today();

        $revenueToday = (int) Order::whereDate('transaction_time', $today)
            ->where('status', Order::STATUS_PAID)->sum('total_price');
        $ordersToday = Order::whereDate('transaction_time', $today)
            ->where('status', Order::STATUS_PAID)->count();

        $revenueYesterday = (int) Order::whereDate('transaction_time', $today->copy()->subDay())
            ->where('status', Order::STATUS_PAID)->sum('total_price');
        $revenueDelta = $revenueYesterday > 0
            ? round((($revenueToday - $revenueYesterday) / $revenueYesterday) * 100, 1)
            : null;

        $startWeek = $today->copy()->startOfWeek();
        $startMonth = $today->copy()->startOfMonth();
        $quickStats = [
            'revenue_week' => (int) Order::whereBetween('transaction_time', [$startWeek, now()])
                ->where('status', Order::STATUS_PAID)->sum('total_price'),
            'revenue_month' => (int) Order::whereBetween('transaction_time', [$startMonth, now()])
                ->where('status', Order::STATUS_PAID)->sum('total_price'),
            'avg_per_order' => (int) (Order::whereDate('transaction_time', $today)
                ->where('status', Order::STATUS_PAID)->avg('total_price') ?? 0),
            'items_sold_today' => (int) Order::whereDate('transaction_time', $today)
                ->where('status', Order::STATUS_PAID)->sum('total_item'),
        ];

        $stats = [
            'revenue_today' => $revenueToday,
            'orders_today' => $ordersToday,
            'total_products' => Product::count(),
            'active_users' => User::where('roles', 'kasir')->where('is_active', true)->count(),
            'revenue_delta' => $revenueDelta,
        ];

        $topProducts = OrderItem::select('product_id', DB::raw('SUM(quantity) as total_sold'))
            ->with('product:id,name,price,image')
            ->groupBy('product_id')
            ->orderByDesc('total_sold')
            ->limit(5)->get();

        $recentOrders = Order::with('kasir:id,name')
            ->latest('transaction_time')
            ->limit(8)->get();

        $lowStock = Product::where('stock', '<', 5)
            ->orderBy('stock')->limit(10)->get();

        $paymentBreakdown = Order::whereDate('transaction_time', $today)
            ->where('status', Order::STATUS_PAID)
            ->select('payment_method', DB::raw('SUM(total_price) as total'))
            ->groupBy('payment_method')->get();

        return view('pages.dashboard', compact(
            'stats', 'quickStats', 'topProducts', 'recentOrders', 'lowStock', 'paymentBreakdown'
        ));
    }
}
