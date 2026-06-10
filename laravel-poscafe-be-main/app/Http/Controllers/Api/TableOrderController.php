<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Http\Responses\ApiResponse;
use App\Models\Order;
use Illuminate\Http\Request;

class TableOrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::query()
            ->with(['diningTable', 'orderItems.product'])
            ->where('order_source', Order::SOURCE_TABLE_QR);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        } else {
            $query->whereNotIn('status', [Order::STATUS_COMPLETED, Order::STATUS_CANCELLED]);
        }

        $paginator = $query->latest('transaction_time')->paginate(30);

        $items = collect($paginator->items())
            ->map(fn (Order $order) => (new OrderResource($order))->resolve())
            ->values()
            ->all();

        return ApiResponse::success($items, 'OK', 200, [
            'total' => $paginator->total(),
            'current_page' => $paginator->currentPage(),
            'last_page' => $paginator->lastPage(),
        ]);
    }

    public function pendingCount()
    {
        $count = Order::query()
            ->where('order_source', Order::SOURCE_TABLE_QR)
            ->whereNotIn('status', [Order::STATUS_COMPLETED, Order::STATUS_CANCELLED])
            ->count();

        return ApiResponse::success(['count' => $count]);
    }

    public function show(Order $order)
    {
        abort_unless($order->isTableOrder(), 404);

        $order->load(['diningTable', 'orderItems.product', 'confirmedBy']);

        return ApiResponse::success((new OrderResource($order))->resolve());
    }

    public function confirm(Request $request, Order $order)
    {
        abort_unless($order->status === Order::STATUS_AWAITING_CONFIRMATION, 422);
        $order->update([
            'status' => Order::STATUS_PAID,
            'amount_paid' => $order->total_price,
            'confirmed_by_user_id' => $request->user()->id,
            'confirmed_at' => now(),
        ]);

        return ApiResponse::success(new OrderResource($order->fresh()));
    }

    public function reject(Order $order)
    {
        abort_unless($order->status === Order::STATUS_AWAITING_CONFIRMATION, 422);
        $order->update(['status' => Order::STATUS_CANCELLED]);

        return ApiResponse::success(new OrderResource($order->fresh()));
    }

    public function updateStatus(Request $request, Order $order)
    {
        abort_unless($order->isTableOrder(), 404);
        $data = $request->validate([
            'status' => ['required', 'in:preparing,ready,completed,cancelled'],
        ]);

        $allowed = match ($order->status) {
            Order::STATUS_PAID, Order::STATUS_AWAITING_CONFIRMATION => ['preparing', 'cancelled'],
            Order::STATUS_PREPARING, Order::STATUS_READY => ['completed', 'cancelled'],
            default => [],
        };

        if (! in_array($data['status'], $allowed, true)) {
            return ApiResponse::error('Transisi status tidak valid.', 422);
        }

        $updates = ['status' => $data['status']];
        if ($data['status'] === 'preparing' && ! $order->amount_paid) {
            $updates['amount_paid'] = $order->total_price;
        }
        $order->update($updates);

        return ApiResponse::success(new OrderResource($order->fresh()));
    }
}
