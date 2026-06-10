@extends('layouts.app')
@section('title', __('Edit Produk'))
@section('page-title', __('Edit Produk'))
@section('main')
<x-page-header :title="'Edit: ' . $product->name"
    :breadcrumbs="[['label' => 'Produk', 'url' => route('product.index')], ['label' => 'Edit']]" />
@include('pages.products._form')
@endsection
