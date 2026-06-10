<?php

namespace App\Http\Controllers;

use App\Exports\OrdersExport;
use App\Models\Order;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Order::class);

        $query = Order::with('kasir:id,name');

        if (! $request->user()->isAdmin()) {
            $query->where('kasir_id', $request->user()->id);
        }

        if ($request->filled('q')) {
            $query->where(function ($q) use ($request) {
                $q->where('order_number', 'like', '%'.$request->q.'%')
                  ->orWhere('customer_name', 'like', '%'.$request->q.'%');
            });
        }
        if ($request->filled('date_from')) {
            $query->whereDate('transaction_time', '>=', $request->date_from);
        }
        if ($request->filled('date_to')) {
            $query->whereDate('transaction_time', '<=', $request->date_to);
        }
        if ($request->filled('payment_method')) {
            $query->where('payment_method', $request->payment_method);
        }
        if ($request->filled('kasir_id') && $request->user()->isAdmin()) {
            $query->where('kasir_id', $request->kasir_id);
        }
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $totalRevenue = (int) (clone $query)->where('status', Order::STATUS_PAID)->sum('total_price');
        $orders = $query->latest('transaction_time')->paginate(20)->withQueryString();
        $totalOrders = $orders->total();

        $kasirList = $request->user()->isAdmin()
            ? User::where('roles', 'kasir')->orderBy('name')->get(['id', 'name'])
            : collect();
        $paymentMethods = ['cash', 'qris', 'transfer'];

        return view('pages.orders.index', compact('orders', 'totalRevenue', 'totalOrders', 'kasirList', 'paymentMethods'));
    }

    public function show(Order $order)
    {
        $this->authorize('view', $order);
        $orderItems = $order->orderItems()->with('product')->get();

        return view('pages.orders.view', compact('order', 'orderItems'));
    }

    public function destroy(Order $order)
    {
        $this->authorize('delete', $order);
        $order->delete();

        return redirect()->route('order.index')->with('success', __('messages.deleted', ['resource' => 'Pesanan']));
    }

    public function receipt(Order $order)
    {
        $this->authorize('view', $order);
        $orderItems = $order->orderItems()->with('product')->get();

        return view('pages.orders.receipt', compact('order', 'orderItems'));
    }

    public function invoicePdf(Order $order)
    {
        $this->authorize('view', $order);
        $orderItems = $order->orderItems()->with('product')->get();
        $pdf = Pdf::loadView('pages.orders.invoice-pdf', compact('order', 'orderItems'))->setPaper('A4');

        return $pdf->download($order->order_number.'.pdf');
    }

    public function export(Request $request)
    {
        $this->authorize('viewAny', Order::class);

        return Excel::download(new OrdersExport($request->all()), 'orders-'.now()->format('Ymd').'.xlsx');
    }
}
