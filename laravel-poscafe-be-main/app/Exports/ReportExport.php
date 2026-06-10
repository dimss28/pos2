<?php

namespace App\Exports;

use App\Models\Order;
use Barryvdh\DomPDF\Facade\Pdf;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;

class ReportExport implements FromCollection, WithHeadings, WithTitle
{
    public function __construct(
        protected string $type,
        protected array $filters,
        protected $from,
        protected $to,
    ) {}

    public function collection()
    {
        return collect($this->buildData()['rows']);
    }

    public function headings(): array
    {
        return $this->buildData()['headings'];
    }

    public function title(): string
    {
        return ucfirst($this->type);
    }

    public function toPdf()
    {
        $data = $this->buildData();
        return Pdf::loadView('pages.reports.pdf', [
            'title'    => $this->type,
            'rows'     => $data['rows'],
            'headings' => $data['headings'],
            'from'     => $this->from,
            'to'       => $this->to,
        ])->setPaper('A4', 'landscape')->download("report-{$this->type}.pdf");
    }

    private function buildData(): array
    {
        return match ($this->type) {
            'summary' => [
                'headings' => ['Tanggal', 'Total Order', 'Revenue'],
                'rows'     => Order::whereBetween('transaction_time', [$this->from, $this->to])
                    ->where('status', Order::STATUS_PAID)
                    ->selectRaw('DATE(transaction_time) tgl, COUNT(*) total, SUM(total_price) rev')
                    ->groupBy('tgl')->get()
                    ->map(fn ($r) => [$r->tgl, $r->total, $r->rev])->toArray(),
            ],
            'product-sales' => [
                'headings' => ['Produk', 'Kategori', 'Qty', 'Revenue'],
                'rows'     => \App\Models\OrderItem::join('orders', 'order_items.order_id', '=', 'orders.id')
                    ->join('products', 'order_items.product_id', '=', 'products.id')
                    ->leftJoin('categories', 'products.category_id', '=', 'categories.id')
                    ->whereBetween('orders.transaction_time', [$this->from, $this->to])
                    ->where('orders.status', Order::STATUS_PAID)
                    ->selectRaw('products.name, COALESCE(categories.name,"Lainnya") cat, SUM(order_items.quantity) qty, SUM(order_items.total_price) rev')
                    ->groupBy('products.id', 'products.name', 'categories.name')
                    ->orderByDesc('rev')->get()
                    ->map(fn ($r) => [$r->name, $r->cat, $r->qty, $r->rev])->toArray(),
            ],
            'close-cashier' => [
                'headings' => ['Kasir', 'Pembayaran', 'Transaksi', 'Revenue'],
                'rows'     => Order::join('users', 'orders.kasir_id', '=', 'users.id')
                    ->whereBetween('transaction_time', [$this->from, $this->to])
                    ->where('status', Order::STATUS_PAID)
                    ->selectRaw('users.name kasir, payment_method, COUNT(*) trx, SUM(total_price) rev')
                    ->groupBy('users.id', 'users.name', 'payment_method')
                    ->orderBy('users.name')->get()
                    ->map(fn ($r) => [$r->kasir, strtoupper($r->payment_method), $r->trx, $r->rev])->toArray(),
            ],
            'promo-usage' => [
                'headings' => ['Promo', 'Kode', 'Tipe', 'Pemakaian', 'Total Diskon'],
                'rows'     => \App\Models\Promo::leftJoin('orders', function ($join) {
                        $join->on('promos.id', '=', 'orders.promo_id')
                             ->whereBetween('orders.transaction_time', [$this->from, $this->to]);
                    })
                    ->selectRaw('promos.name, promos.code, promos.type, COUNT(orders.id) used, COALESCE(SUM(orders.discount_amount),0) disc')
                    ->groupBy('promos.id', 'promos.name', 'promos.code', 'promos.type')
                    ->orderByDesc('used')->get()
                    ->map(fn ($r) => [$r->name, $r->code ?? '-', $r->type, $r->used, $r->disc])->toArray(),
            ],
            'sales-analytics' => [
                'headings' => ['Jam', 'Transaksi', 'Revenue'],
                'rows'     => Order::whereBetween('transaction_time', [$this->from, $this->to])
                    ->where('status', Order::STATUS_PAID)
                    ->selectRaw('HOUR(transaction_time) jam, COUNT(*) trx, SUM(total_price) rev')
                    ->groupBy('jam')->orderBy('jam')->get()
                    ->map(fn ($r) => [$r->jam.':00', $r->trx, $r->rev])->toArray(),
            ],
            'inventory' => [
                'headings' => ['Produk', 'Kategori', 'Stok', 'Terjual', 'Nilai Stok'],
                'rows'     => \App\Models\Product::leftJoin('order_items', 'order_items.product_id', '=', 'products.id')
                    ->leftJoin('categories', 'products.category_id', '=', 'categories.id')
                    ->selectRaw('products.name, COALESCE(categories.name,"Lainnya") cat, products.stock, COALESCE(SUM(order_items.quantity),0) sold, products.stock * products.price val')
                    ->groupBy('products.id', 'products.name', 'products.stock', 'products.price', 'categories.name')
                    ->orderBy('products.stock')->get()
                    ->map(fn ($r) => [$r->name, $r->cat, $r->stock, $r->sold, $r->val])->toArray(),
            ],
            default => ['headings' => [], 'rows' => []],
        };
    }
}
