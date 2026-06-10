<?php

namespace App\Http\Controllers;

use App\Models\CashSession;
use App\Models\Order;
use Illuminate\Http\Request;

class CashSessionController extends Controller
{
    public function index(Request $request)
    {
        $query = CashSession::with('user:id,name')->withCount('orders');
        if (! $request->user()->isAdmin()) {
            $query->forUser($request->user()->id);
        }
        if ($request->filled('status')) {
            $request->status === 'open' ? $query->whereNull('closed_at') : $query->whereNotNull('closed_at');
        }
        if ($request->filled('date_from')) {
            $query->whereDate('opened_at', '>=', $request->date_from);
        }
        if ($request->filled('date_to')) {
            $query->whereDate('opened_at', '<=', $request->date_to);
        }

        $sessions = $query->latest('opened_at')->paginate(20)->withQueryString();
        $mySession = CashSession::currentFor($request->user()->id);

        // Stats
        $stats = [
            'open_now' => CashSession::open()->count(),
            'closed_today' => CashSession::whereDate('closed_at', today())->count(),
            'variance_today' => (int) CashSession::whereDate('closed_at', today())->sum('variance'),
            'cash_revenue_today' => (int) Order::whereDate('transaction_time', today())
                ->where('payment_method', 'cash')->where('status', Order::STATUS_PAID)->sum('amount_paid'),
        ];

        return view('pages.cash-sessions.index', compact('sessions', 'mySession', 'stats'));
    }

    public function open(Request $request)
    {
        $data = $request->validate([
            'shift_label' => ['required', 'in:Pagi,Siang,Malam'],
            'opening_float' => ['required', 'integer', 'min:0'],
            'opening_note' => ['nullable', 'string', 'max:500'],
        ]);
        if (CashSession::open()->forUser($request->user()->id)->exists()) {
            return back()->with('error', __('Anda sudah punya shift aktif.'));
        }
        $session = CashSession::create($data + [
            'user_id' => $request->user()->id,
            'opened_at' => now(),
        ]);

        return redirect()->route('cash-session.show', $session)->with('success', __('Shift dibuka.'));
    }

    public function show(CashSession $cashSession)
    {
        $this->authorize('view', $cashSession);
        $orders = $cashSession->orders()->with('orderItems')->latest('transaction_time')->get();
        $revenueByMethod = $cashSession->revenueByMethod();
        $cashRevenue = $cashSession->cashRevenue();
        $expectedCash = $cashSession->opening_float + $cashSession->cash_in - $cashSession->cash_out + $cashRevenue;

        return view('pages.cash-sessions.show', compact('cashSession', 'orders', 'revenueByMethod', 'cashRevenue', 'expectedCash'));
    }

    public function close(Request $request, CashSession $cashSession)
    {
        $this->authorize('view', $cashSession);
        $data = $request->validate([
            'physical_count' => ['required', 'integer', 'min:0'],
            'cash_in' => ['nullable', 'integer', 'min:0'],
            'cash_out' => ['nullable', 'integer', 'min:0'],
            'closing_note' => ['nullable', 'string', 'max:500'],
        ]);
        if ($cashSession->closed_at) {
            return back()->with('error', __('Shift sudah ditutup.'));
        }

        $cashRevenue = $cashSession->cashRevenue();
        $expected = $cashSession->opening_float + ($data['cash_in'] ?? 0) - ($data['cash_out'] ?? 0) + $cashRevenue;
        $variance = $data['physical_count'] - $expected;

        $cashSession->update($data + [
            'expected_cash' => $expected,
            'variance' => $variance,
            'closed_at' => now(),
        ]);

        return redirect()->route('cash-session.show', $cashSession)
            ->with('success', $variance === 0 ? __('Shift ditutup. Saldo balanced.') : __('Shift ditutup. Selisih: :v', ['v' => rupiah($variance)]));
    }

    public function forceClose(Request $request, CashSession $cashSession)
    {
        $this->authorize('forceClose', $cashSession);
        $cashRevenue = $cashSession->cashRevenue();
        $expected = $cashSession->opening_float + $cashSession->cash_in - $cashSession->cash_out + $cashRevenue;
        $cashSession->update([
            'physical_count' => $expected, // assume balanced
            'expected_cash' => $expected,
            'variance' => 0,
            'closing_note' => '[Force-closed oleh '.$request->user()->name.']',
            'closed_at' => now(),
        ]);

        return back()->with('success', __('Shift di-force close.'));
    }
}
