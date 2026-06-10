<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Http\Responses\ApiResponse;
use App\Models\CashSession;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RefundController extends Controller
{
    public function store(Request $request, Order $order)
    {
        abort_unless($request->user()->isOwner(), 403);

        if ($order->status !== Order::STATUS_PAID) {
            return ApiResponse::error('Order tidak bisa di-refund.', 422);
        }

        $data = $request->validate([
            'reason' => ['required', 'string', 'max:64'],
            'note' => ['nullable', 'string', 'max:500'],
        ]);

        DB::transaction(function () use ($order, $data, $request) {
            $order->update([
                'status' => Order::STATUS_REFUNDED,
                'refunded_at' => now(),
                'refund_reason' => $data['reason'],
                'refund_note' => $data['note'] ?? null,
                'refund_amount' => $order->total_price,
                'refunded_by_user_id' => $request->user()->id,
            ]);

            foreach ($order->orderItems as $it) {
                Product::where('id', $it->product_id)->increment('stock', $it->quantity);
            }

            if ($order->cash_session_id) {
                CashSession::where('id', $order->cash_session_id)->increment('cash_out', $order->total_price);
            }
        });

        return ApiResponse::success(
            new OrderResource($order->fresh()->load('orderItems.product', 'kasir')),
            'Order di-refund.'
        );
    }
}
