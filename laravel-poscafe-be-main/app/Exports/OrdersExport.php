<?php

namespace App\Exports;

use App\Models\Order;
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class OrdersExport implements FromQuery, ShouldAutoSize, WithHeadings, WithMapping, WithStyles
{
    public function __construct(protected array $filters) {}

    public function query()
    {
        $query = Order::with('kasir:id,name');
        $f = $this->filters;

        if (! empty($f['q'])) {
            $query->where(function ($q) use ($f) {
                $q->where('order_number', 'like', '%'.$f['q'].'%')
                  ->orWhere('customer_name', 'like', '%'.$f['q'].'%');
            });
        }
        if (! empty($f['date_from'])) {
            $query->whereDate('transaction_time', '>=', $f['date_from']);
        }
        if (! empty($f['date_to'])) {
            $query->whereDate('transaction_time', '<=', $f['date_to']);
        }
        if (! empty($f['payment_method'])) {
            $query->where('payment_method', $f['payment_method']);
        }
        if (! empty($f['kasir_id'])) {
            $query->where('kasir_id', $f['kasir_id']);
        }
        if (! empty($f['status'])) {
            $query->where('status', $f['status']);
        }

        return $query->latest('transaction_time');
    }

    public function headings(): array
    {
        return ['Order #', 'Tanggal', 'Kasir', 'Customer', 'Items', 'Subtotal', 'Diskon', 'Pajak', 'Total', 'Pembayaran', 'Status'];
    }

    public function map($order): array
    {
        return [
            $order->order_number,
            $order->transaction_time?->format('Y-m-d H:i'),
            $order->kasir->name ?? '',
            $order->customer_name,
            $order->total_item,
            $order->subtotal,
            $order->discount,
            $order->tax,
            $order->total_price,
            strtoupper((string) $order->payment_method),
            $order->statusLabel(),
        ];
    }

    public function styles(Worksheet $sheet): array
    {
        return [1 => ['font' => ['bold' => true]]];
    }
}
