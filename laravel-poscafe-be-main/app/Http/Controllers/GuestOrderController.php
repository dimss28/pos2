<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\DiningTable;
use App\Models\Order;
use App\Models\Product;
use App\Models\StoreSetting;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class GuestOrderController extends Controller
{
    public function show(string $token)
    {
        $table = DiningTable::findByToken($token);
        if (! $table) {
            abort(404, 'Meja tidak ditemukan atau tidak aktif.');
        }

        $categories = Category::with(['products' => fn ($q) => $q->where('stock', '>', 0)])
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get()
            ->filter(fn ($c) => $c->products->isNotEmpty());

        $transfer = StoreSetting::transferBank();
        $midtransReady = StoreSetting::isQrisEnabled();

        return view('guest.order', compact('table', 'categories', 'transfer', 'midtransReady'));
    }

    public function checkout(Request $request, string $token)
    {
        $table = DiningTable::findByToken($token);
        if (! $table) {
            return response()->json(['message' => 'Meja tidak valid.'], 404);
        }

        $data = $request->validate([
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:99'],
            'payment_method' => ['required', 'in:qris,transfer'],
            'customer_name' => ['nullable', 'string', 'max:100'],
            'notes' => ['nullable', 'string', 'max:500'],
            'payment_proof' => ['required_if:payment_method,transfer', 'file', 'image', 'max:5120'],
        ]);

        if ($data['payment_method'] === 'transfer' && ! StoreSetting::isTransferConfigured()) {
            return response()->json(['message' => 'Rekening transfer belum diatur admin.'], 422);
        }

        if ($data['payment_method'] === 'qris' && ! StoreSetting::isQrisEnabled()) {
            return response()->json(['message' => 'QRIS belum diaktifkan admin.'], 422);
        }

        $lines = [];
        $subtotal = 0;
        $totalQty = 0;
        foreach ($data['items'] as $row) {
            $product = Product::findOrFail($row['product_id']);
            if ($product->stock < $row['quantity']) {
                return response()->json([
                    'message' => "{$product->name} stok tidak cukup.",
                ], 422);
            }
            $lineTotal = $product->price * $row['quantity'];
            $subtotal += $lineTotal;
            $totalQty += $row['quantity'];
            $lines[] = [
                'product' => $product,
                'quantity' => $row['quantity'],
                'total_price' => $lineTotal,
            ];
        }

        return DB::transaction(function () use ($data, $table, $lines, $subtotal, $totalQty, $request) {
            $midtransOrderId = 'TBL-'.$table->id.'-'.now()->format('YmdHis').'-'.Str::upper(Str::random(4));

            $order = Order::create([
                'transaction_time' => now(),
                'order_source' => Order::SOURCE_TABLE_QR,
                'dining_table_id' => $table->id,
                'kasir_id' => null,
                'cash_session_id' => null,
                'payment_method' => $data['payment_method'],
                'status' => $data['payment_method'] === 'transfer'
                    ? Order::STATUS_AWAITING_CONFIRMATION
                    : Order::STATUS_AWAITING_PAYMENT,
                'subtotal' => $subtotal,
                'discount' => 0,
                'discount_amount' => 0,
                'tax' => 0,
                'total_price' => $subtotal,
                'amount_paid' => 0,
                'change_amount' => 0,
                'total_item' => $totalQty,
                'customer_name' => $data['customer_name'] ?? null,
                'notes' => $data['notes'] ?? null,
                'midtrans_order_id' => $data['payment_method'] === 'qris' ? $midtransOrderId : null,
            ]);

            foreach ($lines as $line) {
                $order->orderItems()->create([
                    'product_id' => $line['product']->id,
                    'quantity' => $line['quantity'],
                    'total_price' => $line['total_price'],
                ]);
                $line['product']->decrement('stock', $line['quantity']);
            }

            if ($data['payment_method'] === 'transfer') {
                $path = $request->file('payment_proof')->store('payment-proofs', 'public');
                $order->update(['payment_proof_path' => $path]);

                return response()->json([
                    'success' => true,
                    'order_id' => $order->id,
                    'status' => $order->status,
                    'message' => 'Pesanan dikirim. Menunggu konfirmasi kasir.',
                ]);
            }

            $charge = app(MidtransService::class)->chargeQris($midtransOrderId, $subtotal);

            return response()->json([
                'success' => true,
                'order_id' => $order->id,
                'status' => $order->status,
                'qr_url' => $charge['qr_url'],
                'midtrans_order_id' => $midtransOrderId,
                'total' => $subtotal,
            ]);
        });
    }

    public function paymentStatus(string $token, Order $order)
    {
        $table = DiningTable::findByToken($token);
        if (! $table || $order->dining_table_id !== $table->id) {
            return response()->json(['message' => 'Order tidak valid.'], 404);
        }

        if ($order->payment_method === 'qris' && $order->midtrans_order_id) {
            $status = app(MidtransService::class)->transactionStatus($order->midtrans_order_id);
            if ($status === 'settlement' && $order->status === Order::STATUS_AWAITING_PAYMENT) {
                $order->update([
                    'status' => Order::STATUS_PAID,
                    'amount_paid' => $order->total_price,
                ]);
            }
        }

        return response()->json([
            'order_id' => $order->id,
            'status' => $order->status,
            'status_label' => $order->statusLabel(),
            'payment_method' => $order->payment_method,
        ]);
    }
}
