<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;

class TableOrderController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()->isAdmin() || $request->user()->isKasir(), 403);

        $query = Order::query()
            ->with(['diningTable', 'orderItems.product'])
            ->where('order_source', Order::SOURCE_TABLE_QR);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        } else {
            $query->whereNotIn('status', [Order::STATUS_COMPLETED, Order::STATUS_CANCELLED]);
        }

        $orders = $query->latest('transaction_time')->paginate(30)->withQueryString();

        return view('pages.table-orders.index', compact('orders'));
    }

    public function show(Order $order)
    {
        abort_unless($order->isTableOrder(), 404);
        $order->load(['diningTable', 'orderItems.product', 'confirmedBy']);

        return view('pages.table-orders.show', compact('order'));
    }

    public function confirm(Request $request, Order $order)
    {
        abort_unless($order->isTableOrder(), 404);
        abort_unless($order->status === Order::STATUS_AWAITING_CONFIRMATION, 422);

        $order->update([
            'status' => Order::STATUS_PAID,
            'amount_paid' => $order->total_price,
            'confirmed_by_user_id' => $request->user()->id,
            'confirmed_at' => now(),
        ]);

        return back()->with('success', __('Pembayaran transfer dikonfirmasi.'));
    }

    public function reject(Request $request, Order $order)
    {
        abort_unless($order->isTableOrder(), 404);
        abort_unless($order->status === Order::STATUS_AWAITING_CONFIRMATION, 422);

        $order->update(['status' => Order::STATUS_CANCELLED]);

        return back()->with('success', __('Pesanan ditolak.'));
    }

    public function updateStatus(Request $request, Order $order)
    {
        abort_unless($order->isTableOrder(), 404);
        $data = $request->validate([
            'status' => ['required', 'in:preparing,ready,completed,cancelled'],
        ]);

        $allowed = match ($order->status) {
            Order::STATUS_PAID => ['preparing', 'cancelled'],
            Order::STATUS_PREPARING => ['ready', 'cancelled'],
            Order::STATUS_READY => ['completed', 'cancelled'],
            default => [],
        };

        if (! in_array($data['status'], $allowed, true)) {
            return back()->with('error', __('Transisi status tidak valid.'));
        }

        $order->update(['status' => $data['status']]);

        return back()->with('success', __('Status pesanan diperbarui.'));
    }
}
