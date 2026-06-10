@extends('layouts.app')
@section('title', 'Component Showcase')
@section('page-title', 'Component Showcase')
@section('main')

<x-page-header title="Showcase Komponen" subtitle="Demo semua komponen Blade"
    :breadcrumbs="[['label' => 'Dashboard', 'url' => route('home')], ['label' => 'Showcase']]">
    <x-slot:actions>
        <x-button variant="primary" icon="plus">Tambah</x-button>
        <x-button variant="ghost" icon="download">Export</x-button>
    </x-slot:actions>
</x-page-header>

<x-card title="Buttons" subtitle="6 variant + 3 ukuran">
    <div class="d-flex flex-wrap gap-2 mb-2">
        @foreach (['primary','secondary','success','warning','danger','ghost'] as $v)
            <x-button :variant="$v" icon="star">{{ ucfirst($v) }}</x-button>
        @endforeach
    </div>
    <div class="d-flex flex-wrap gap-2 align-items-center">
        <x-button variant="primary" size="sm">Small</x-button>
        <x-button variant="primary" size="md">Medium</x-button>
        <x-button variant="primary" size="lg">Large</x-button>
        <x-button variant="primary" :loading="true">Loading</x-button>
        <x-button variant="primary" icon="external-link-alt" href="#">Link</x-button>
    </div>
</x-card>

<div class="row g-3 my-3">
    <div class="col-md-3"><x-stat-card label="Penjualan" value="Rp 1,2 jt" icon="dollar-sign" color="primary" :delta="12" /></div>
    <div class="col-md-3"><x-stat-card label="Pesanan" value="48" icon="receipt" color="success" :delta="-5" /></div>
    <div class="col-md-3"><x-stat-card label="Produk" value="120" icon="box-open" color="warning" /></div>
    <div class="col-md-3"><x-stat-card label="Refund" value="2" icon="undo" color="danger" :delta="20" /></div>
</div>

<x-card title="Form Components" class="mb-3">
    <form>
        <div class="row">
            <div class="col-md-6">
                <x-form-input name="nama" label="Nama Produk" placeholder="Cappuccino" required />
                <x-form-input name="harga" label="Harga" type="number" icon="dollar-sign" required />
                <x-form-select name="kategori" label="Kategori" placeholder="Pilih..."
                    :options="['1' => 'Kopi', '2' => 'Non Kopi', '3' => 'Snack']" required />
            </div>
            <div class="col-md-6">
                <x-form-textarea name="deskripsi" label="Deskripsi" rows="3" maxlength="100" :counter="true" />
                <x-form-toggle name="aktif" label="Produk aktif" :checked="true" help="Matikan untuk sembunyikan dari menu." />
                <x-form-checkbox name="bestseller" label="Tandai sebagai bestseller" />
            </div>
        </div>
    </form>
</x-card>

<div class="row g-3 mb-3">
    <div class="col-md-6">
        <x-card title="Badges">
            <div class="d-flex flex-wrap gap-2 mb-2">
                @foreach (['pending', 'paid', 'cancelled', 'refunded'] as $s)
                    <x-order-status-badge :status="$s" />
                @endforeach
            </div>
            <div class="d-flex flex-wrap gap-2">
                @foreach (['owner', 'admin', 'kasir'] as $r)
                    <x-role-badge :role="$r" />
                @endforeach
            </div>
        </x-card>
    </div>
    <div class="col-md-6">
        <x-card title="Modal & Sort Link">
            <x-button variant="primary" icon="window-maximize" x-data="" onclick="bootstrap.Modal.getOrCreateInstance(document.getElementById('demoModal')).show()">Buka Modal</x-button>
            <div class="mt-3">
                Sort: <x-sort-link column="nama">Nama</x-sort-link> ·
                <x-sort-link column="harga">Harga</x-sort-link>
            </div>
        </x-card>
    </div>
</div>

<x-card title="Empty State">
    <x-empty-state icon="box-open" title="Belum ada produk" description="Tambahkan produk pertama Anda."
        actionLabel="Tambah Produk" actionUrl="#" />
</x-card>

<div class="my-3">
    <x-card title="Loading Skeleton">
        <x-loading-skeleton :rows="4" :height="14" />
    </x-card>
</div>

<x-card title="Reports Filter">
    <x-reports-filter-bar action="#" :from="now()->subDays(7)->toDateString()" :to="now()->toDateString()"
        :kasirList="[1 => 'Kasir 1', 2 => 'Kasir 2']"
        :categoryList="[1 => 'Kopi', 2 => 'Snack']"
        :showKasir="true" :showCategory="true" :showPayment="true" :showStatus="true"
        :exportUrls="['xlsx' => '#', 'pdf' => '#']" />
</x-card>

<x-modal id="demoModal" title="Demo Modal" size="md">
    <p>Konten modal di sini.</p>
    <x-slot:footer>
        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Batal</button>
        <x-button variant="primary" icon="check">Simpan</x-button>
    </x-slot:footer>
</x-modal>

@endsection
