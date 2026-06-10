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

        return OrderResource::collection(
            $query->latest('transaction_time')->paginate(30)
        );
    }

    public function show(Order $order)
    {
        abort_unless($order->isTableOrder(), 404);

        return ApiResponse::success(
            new OrderResource($order->load(['diningTable', 'orderItems.product', 'confirmedBy']))
        );
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
            Order::STATUS_PAID => ['preparing', 'cancelled'],
            Order::STATUS_PREPARING => ['ready', 'cancelled'],
            Order::STATUS_READY => ['completed', 'cancelled'],
            default => [],
        };

        if (! in_array($data['status'], $allowed, true)) {
            return ApiResponse::error('Transisi status tidak valid.', 422);
        }

        $order->update(['status' => $data['status']]);

        return ApiResponse::success(new OrderResource($order->fresh()));
    }
}
