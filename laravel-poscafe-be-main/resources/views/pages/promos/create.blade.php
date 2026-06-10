@extends('layouts.app')
@section('title', __('Tambah Promo'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Tambah Promo') }}"
        :breadcrumbs="[['label'=>__('Promo'),'url'=>route('promo.index')], ['label'=>__('Tambah')]]"/>

    @include('pages.promos._form')
</section>
@endsection
