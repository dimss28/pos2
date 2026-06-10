@extends('layouts.app')
@section('title', __('Tambah Produk'))
@section('page-title', __('Tambah Produk'))
@section('main')
<x-page-header title="Tambah Produk"
    :breadcrumbs="[['label' => 'Produk', 'url' => route('product.index')], ['label' => 'Tambah']]" />
@include('pages.products._form')
@endsection
