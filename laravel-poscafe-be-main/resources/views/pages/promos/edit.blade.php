@extends('layouts.app')
@section('title', __('Edit Promo'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Edit Promo') }}"
        :breadcrumbs="[['label'=>__('Promo'),'url'=>route('promo.index')], ['label'=>__('Edit')]]"/>

    @include('pages.promos._form')
</section>
@endsection
