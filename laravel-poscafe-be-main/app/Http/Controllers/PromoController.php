<?php

namespace App\Http\Controllers;

use App\Models\Promo;
use App\Http\Requests\PromoRequest;
use Illuminate\Http\Request;

class PromoController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Promo::class);
        $query = Promo::withCount('orders');
        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->q.'%');
        }
        if ($request->filled('status')) {
            match($request->status) {
                'live' => $query->live(),
                'inactive' => $query->where('active', false),
                'scheduled' => $query->where('active', true)->where('starts_at', '>', now()),
                'expired' => $query->where('ends_at', '<', now()),
                default => null,
            };
        }
        $promos = $query->latest()->paginate(15)->withQueryString();

        return view('pages.promos.index', compact('promos'));
    }

    public function create()
    {
        $this->authorize('create', Promo::class);
        return view('pages.promos.create', ['promo' => new Promo(['type' => 'percent', 'active' => true])]);
    }

    public function store(PromoRequest $request)
    {
        $this->authorize('create', Promo::class);
        $data = $request->validated();
        if (! empty($data['code'])) {
            $data['code'] = strtoupper($data['code']);
        }
        Promo::create($data);

        return redirect()->route('promo.index')->with('success', __('messages.created', ['resource' => 'Promo']));
    }

    public function edit(Promo $promo)
    {
        $this->authorize('update', $promo);
        return view('pages.promos.edit', compact('promo'));
    }

    public function update(PromoRequest $request, Promo $promo)
    {
        $this->authorize('update', $promo);
        $data = $request->validated();
        if (! empty($data['code'])) {
            $data['code'] = strtoupper($data['code']);
        }
        $promo->update($data);

        return redirect()->route('promo.index')->with('success', __('messages.updated', ['resource' => 'Promo']));
    }

    public function toggle(Promo $promo)
    {
        $this->authorize('update', $promo);
        $promo->update(['active' => ! $promo->active]);

        return back()->with('success', __('Status promo diubah.'));
    }

    public function destroy(Promo $promo)
    {
        $this->authorize('delete', $promo);
        if ($promo->orders()->exists()) {
            return back()->with('error', __('Promo tidak bisa dihapus karena sudah dipakai di pesanan.'));
        }
        $promo->delete();

        return back()->with('success', __('messages.deleted', ['resource' => 'Promo']));
    }
}
