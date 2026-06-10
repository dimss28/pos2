<?php

namespace App\Http\Controllers;

use App\Exports\ReportExport;
use App\Models\Category;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\Promo;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

class ReportController extends Controller
{
    public function index()
    {
        return view('pages.reports.index');
    }

    public function summary(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);

        $base = Order::whereBetween('transaction_time', [$from, $to])
                     ->where('status', Order::STATUS_PAID);

        $stats = [
            'total_revenue' => (int) (clone $base)->sum('total_price'),
            'total_orders'  => (clone $base)->count(),
            'total_items'   => (int) (clone $base)->sum('total_item'),
            'avg_per_order' => (int) (clone $base)->avg('total_price'),
        ];

        $daily = (clone $base)
            ->selectRaw('DATE(transaction_time) date, SUM(total_price) total, COUNT(*) count')
            ->groupBy('date')->orderBy('date')->get();

        $perKasir = (clone $base)
            ->join('users', 'orders.kasir_id', '=', 'users.id')
            ->selectRaw('users.name kasir_name, COUNT(*) order_count, SUM(total_price) revenue')
            ->groupBy('users.id', 'users.name')->orderByDesc('revenue')->get();

        $paymentBreakdown = (clone $base)
            ->selectRaw('payment_method, COUNT(*) count, SUM(total_price) total')
            ->groupBy('payment_method')->get();

        return view('pages.reports.summary', compact('stats', 'daily', 'perKasir', 'paymentBreakdown', 'from', 'to'));
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
                         SUM(order_items.quantity) qty_sold,
                         SUM(order_items.total_price) revenue')
            ->groupBy('products.id', 'products.name', 'categories.name')
            ->orderByDesc('revenue')->get();

        $totalRevenue = $rows->sum('revenue');
        return view('pages.reports.product-sales', compact('rows', 'totalRevenue', 'from', 'to'));
    }

    public function closeCashier(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);
        $rows = Order::join('users', 'orders.kasir_id', '=', 'users.id')
            ->whereBetween('transaction_time', [$from, $to])
            ->where('status', Order::STATUS_PAID)
            ->selectRaw('users.name kasir_name, payment_method,
                         COUNT(*) order_count, SUM(total_price) revenue')
            ->groupBy('users.id', 'users.name', 'payment_method')
            ->orderBy('users.name')->orderBy('payment_method')->get();

        return view('pages.reports.close-cashier', compact('rows', 'from', 'to'));
    }

    public function promoUsage(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);
        $rows = Promo::leftJoin('orders', function ($join) use ($from, $to) {
                $join->on('promos.id', '=', 'orders.promo_id')
                     ->whereBetween('orders.transaction_time', [$from, $to]);
            })
            ->selectRaw('promos.id, promos.name, promos.code, promos.type,
                         COUNT(orders.id) usage_count, COALESCE(SUM(orders.discount_amount),0) total_discount')
            ->groupBy('promos.id', 'promos.name', 'promos.code', 'promos.type')
            ->orderByDesc('usage_count')->get();

        return view('pages.reports.promo-usage', compact('rows', 'from', 'to'));
    }

    public function salesAnalytics(Request $request)
    {
        [$from, $to] = $this->resolveRange($request);
        $base = Order::whereBetween('transaction_time', [$from, $to])
                     ->where('status', Order::STATUS_PAID);

        $hourly = (clone $base)
            ->selectRaw('HOUR(transaction_time) hour, COUNT(*) count, SUM(total_price) revenue')
            ->groupBy('hour')->orderBy('hour')->get();

        $dayOfWeek = (clone $base)
            ->selectRaw('DAYOFWEEK(transaction_time) dow, COUNT(*) count, SUM(total_price) revenue')
            ->groupBy('dow')->orderBy('dow')->get();

        $peakHour = $hourly->sortByDesc('revenue')->first()?->hour;
        $bestDay  = $dayOfWeek->sortByDesc('revenue')->first()?->dow;

        $topCategories = OrderItem::join('orders', 'order_items.order_id', '=', 'orders.id')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->leftJoin('categories', 'products.category_id', '=', 'categories.id')
            ->whereBetween('orders.transaction_time', [$from, $to])
            ->where('orders.status', Order::STATUS_PAID)
            ->selectRaw('COALESCE(categories.name,"Lainnya") cat, SUM(order_items.total_price) revenue')
            ->groupBy('cat')->orderByDesc('revenue')->limit(5)->get();

        return view('pages.reports.sales-analytics', compact('hourly', 'dayOfWeek', 'peakHour', 'bestDay', 'topCategories', 'from', 'to'));
    }

    public function inventory(Request $request)
    {
        $filter = $request->stock_filter;
        $query = Product::leftJoin('order_items', 'order_items.product_id', '=', 'products.id')
            ->leftJoin('orders', 'order_items.order_id', '=', 'orders.id')
            ->leftJoin('categories', 'products.category_id', '=', 'categories.id')
            ->selectRaw('products.id, products.name, products.price, products.stock,
                         COALESCE(categories.name,"Lainnya") category_name,
                         COALESCE(SUM(order_items.quantity),0) sold,
                         MAX(orders.transaction_time) last_sold')
            ->groupBy('products.id', 'products.name', 'products.price', 'products.stock', 'categories.name');

        if ($filter === 'out') $query->having('products.stock', '=', 0);
        if ($filter === 'low') $query->havingRaw('products.stock BETWEEN 1 AND 4');

        $rows       = $query->orderBy('products.stock')->get();
        $totalValue = $rows->sum(fn ($r) => $r->stock * $r->price);

        return view('pages.reports.inventory', compact('rows', 'totalValue', 'filter'));
    }

    public function export(string $type, Request $request)
    {
        $format   = $request->get('format', 'xlsx');
        [$from, $to] = $this->resolveRange($request);
        $exporter = new ReportExport($type, $request->all(), $from, $to);

        return match ($format) {
            'csv'  => Excel::download($exporter, "report-{$type}-".now()->format('Ymd').'.csv', \Maatwebsite\Excel\Excel::CSV),
            'pdf'  => $exporter->toPdf(),
            default => Excel::download($exporter, "report-{$type}-".now()->format('Ymd').'.xlsx'),
        };
    }

    private function resolveRange(Request $request): array
    {
        $preset = $request->get('preset', 'today');
        $from   = $request->get('from') ? Carbon::parse($request->get('from'))->startOfDay() : null;
        $to     = $request->get('to')   ? Carbon::parse($request->get('to'))->endOfDay()     : null;

        if (! $from || ! $to) {
            [$from, $to] = match ($preset) {
                'today'  => [today()->startOfDay(), now()],
                'week'   => [now()->startOfWeek(), now()],
                'month'  => [now()->startOfMonth(), now()],
                'year'   => [now()->startOfYear(), now()],
                default  => [today()->startOfDay(), now()],
            };
        }

        return [$from, $to];
    }
}
