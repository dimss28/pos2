<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\ApiOrderStoreRequest;
use App\Http\Resources\OrderResource;
use App\Http\Responses\ApiResponse;
use App\Models\CashSession;
use App\Models\Order;
use App\Models\Product;
use App\Models\Promo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::with('kasir:id,name');
        if ($request->filled('kasir_id')) $query->where('kasir_id', $request->kasir_id);
        if ($request->filled('status')) $query->where('status', $request->status);
        $orders = $query->latest('transaction_time')->paginate(20);

        return OrderResource::collection($orders);
    }

    public function show(Order $order)
    {
        return ApiResponse::success(new OrderResource($order->load('kasir', 'orderItems.product')));
    }

    public function store(ApiOrderStoreRequest $request)
    {
        $user = $request->user();
        $session = CashSession::currentFor($user->id);
        if (! $session) {
            return ApiResponse::error('Buka shift dulu sebelum membuat order.', 422);
        }

        $promo = null;
        $discount = 0;
        if ($request->filled('promo_code')) {
            $promo = Promo::byCode($request->promo_code)->first();
            if ($promo && $promo->isLive() && $request->subtotal >= $promo->min_subtotal) {
                $discount = $promo->computeDiscount((int) $request->subtotal, $request->items);
            }
        } elseif ($request->filled('promo_id')) {
            $promo = Promo::find($request->promo_id);
            if ($promo && $promo->isLive()) {
                $discount = $promo->computeDiscount((int) $request->subtotal, $request->items);
            }
        }

        $totalPrice = max(0, (int) $request->subtotal - $discount + (int) $request->get('tax', 0));

        return DB::transaction(function () use ($request, $session, $promo, $discount, $totalPrice, $user) {
            $order = Order::create([
                'transaction_time' => $request->get('transaction_time', now()),
                'kasir_id' => $user->id,
                'cash_session_id' => $session->id,
                'promo_id' => $promo?->id,
                'subtotal' => $request->subtotal,
                'discount' => $discount,
                'discount_amount' => $discount,
                'tax' => $request->get('tax', 0),
                'total_price' => $totalPrice,
                'amount_paid' => $request->amount_paid,
                'change_amount' => max(0, (int) $request->amount_paid - $totalPrice),
                'total_item' => collect($request->items)->sum('quantity'),
                'payment_method' => $request->payment_method,
                'customer_name' => $request->customer_name,
                'notes' => $request->notes,
            ]);

            foreach ($request->items as $it) {
                $order->orderItems()->create([
                    'product_id' => $it['product_id'],
                    'quantity' => $it['quantity'],
                    'total_price' => $it['total_price'],
                ]);
                Product::where('id', $it['product_id'])->decrement('stock', $it['quantity']);
            }

            return ApiResponse::success(
                new OrderResource($order->load('orderItems.product', 'kasir')),
                'Order dibuat.',
                201
            );
        });
    }

    public function getByKasirId($kasirId)
    {
        $orders = Order::where('kasir_id', $kasirId)->latest('transaction_time')->limit(50)->get();

        return ApiResponse::success(OrderResource::collection($orders));
    }
}
