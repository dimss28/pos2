<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CashSessionResource;
use App\Http\Responses\ApiResponse;
use App\Models\CashSession;
use Illuminate\Http\Request;

class CashSessionController extends Controller
{
    public function index(Request $request)
    {
        $sessions = CashSession::with('user:id,name')
            ->where('user_id', $request->user()->id)
            ->latest('opened_at')->paginate(20);

        return CashSessionResource::collection($sessions);
    }

    public function current(Request $request)
    {
        $session = CashSession::currentFor($request->user()->id);
        if (! $session) {
            return ApiResponse::error('Tidak ada shift aktif.', 404);
        }

        return ApiResponse::success(new CashSessionResource($session->load('user')));
    }

    public function open(Request $request)
    {
        $existing = CashSession::currentFor($request->user()->id);
        if ($existing) {
            return ApiResponse::error('Masih ada shift yang belum ditutup.', 422);
        }

        $data = $request->validate([
            'shift_label' => ['required', 'string', 'max:20'],
            'opening_float' => ['required', 'integer', 'min:0'],
        ]);

        $session = CashSession::create([
            'user_id' => $request->user()->id,
            'shift_label' => $data['shift_label'],
            'opening_float' => $data['opening_float'],
            'opened_at' => now(),
        ]);

        return ApiResponse::success(new CashSessionResource($session), 'Shift dibuka.', 201);
    }

    public function show(int $id, Request $request)
    {
        $session = CashSession::where('user_id', $request->user()->id)->findOrFail($id);

        return ApiResponse::success(new CashSessionResource($session->load('user')));
    }

    public function summary(int $id, Request $request)
    {
        $session = CashSession::where('user_id', $request->user()->id)->findOrFail($id);

        return ApiResponse::success([
            'session' => new CashSessionResource($session),
            'revenue_by_method' => $session->revenueByMethod(),
            'cash_revenue' => $session->cashRevenue(),
            'order_count' => $session->orders()->count(),
        ]);
    }

    public function close(int $id, Request $request)
    {
        $session = CashSession::where('user_id', $request->user()->id)
            ->whereNull('closed_at')->findOrFail($id);

        $data = $request->validate([
            'physical_count' => ['required', 'integer', 'min:0'],
        ]);

        $expectedCash = $session->opening_float + $session->cashRevenue() + $session->cash_in - $session->cash_out;

        $session->update([
            'physical_count' => $data['physical_count'],
            'expected_cash' => $expectedCash,
            'variance' => $data['physical_count'] - $expectedCash,
            'closed_at' => now(),
        ]);

        return ApiResponse::success(new CashSessionResource($session->fresh()), 'Shift ditutup.');
    }
}
