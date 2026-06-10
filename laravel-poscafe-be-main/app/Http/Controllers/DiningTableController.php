<?php

namespace App\Http\Controllers;

use App\Models\DiningTable;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use ZipArchive;

class DiningTableController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', DiningTable::class);
        $tables = DiningTable::query()
            ->when($request->filled('q'), fn ($q) => $q->where('label', 'like', '%'.$request->q.'%'))
            ->orderBy('sort_order')
            ->orderBy('label')
            ->paginate(30)
            ->withQueryString();

        return view('pages.dining-tables.index', compact('tables'));
    }

    public function create()
    {
        $this->authorize('create', DiningTable::class);

        return view('pages.dining-tables.create');
    }

    public function store(Request $request)
    {
        $this->authorize('create', DiningTable::class);
        $data = $request->validate([
            'label' => ['required', 'string', 'max:100'],
            'is_active' => ['nullable', 'boolean'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);
        $data['is_active'] = $request->boolean('is_active', true);
        $data['sort_order'] = $data['sort_order'] ?? 0;
        DiningTable::create($data);

        return redirect()->route('dining-table.index')
            ->with('success', __('Meja berhasil ditambahkan.'));
    }

    public function edit(DiningTable $diningTable)
    {
        $this->authorize('update', $diningTable);

        return view('pages.dining-tables.edit', ['table' => $diningTable]);
    }

    public function update(Request $request, DiningTable $diningTable)
    {
        $this->authorize('update', $diningTable);
        $data = $request->validate([
            'label' => ['required', 'string', 'max:100'],
            'is_active' => ['nullable', 'boolean'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);
        $data['is_active'] = $request->boolean('is_active');
        $diningTable->update($data);

        return redirect()->route('dining-table.index')
            ->with('success', __('Meja berhasil diperbarui.'));
    }

    public function destroy(DiningTable $diningTable)
    {
        $this->authorize('delete', $diningTable);
        $diningTable->delete();

        return back()->with('success', __('Meja berhasil dihapus.'));
    }

    public function regenerateToken(DiningTable $diningTable)
    {
        $this->authorize('update', $diningTable);
        $diningTable->update(['qr_token' => Str::random(48)]);

        return back()->with('success', __('QR token diperbarui. Cetak ulang sticker QR.'));
    }

    public function downloadQr(DiningTable $diningTable)
    {
        $this->authorize('view', $diningTable);
        $png = @file_get_contents($diningTable->qrImageUrl(500));
        if ($png === false) {
            return back()->with('error', __('Gagal membuat gambar QR.'));
        }
        $filename = Str::slug($diningTable->label).'-qr.png';

        return response($png, 200, [
            'Content-Type' => 'image/png',
            'Content-Disposition' => 'attachment; filename="'.$filename.'"',
        ]);
    }

    public function downloadAllQr()
    {
        $this->authorize('viewAny', DiningTable::class);
        $tables = DiningTable::query()->where('is_active', true)->orderBy('sort_order')->get();
        if ($tables->isEmpty()) {
            return back()->with('error', __('Tidak ada meja aktif.'));
        }

        $tmp = tempnam(sys_get_temp_dir(), 'qrzip');
        $zip = new ZipArchive;
        $zip->open($tmp, ZipArchive::OVERWRITE);
        foreach ($tables as $table) {
            $png = @file_get_contents($table->qrImageUrl(500));
            if ($png !== false) {
                $zip->addFromString(Str::slug($table->label).'-qr.png', $png);
            }
        }
        $zip->close();

        return response()->download($tmp, 'qr-meja-'.now()->format('Ymd').'.zip')->deleteFileAfterSend();
    }
}
