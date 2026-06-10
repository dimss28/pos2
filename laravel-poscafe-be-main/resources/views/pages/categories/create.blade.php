@extends('layouts.app')
@section('title', __('Tambah Kategori'))
@section('page-title', __('Tambah Kategori'))
@section('main')
<x-page-header title="Tambah Kategori"
    :breadcrumbs="[['label' => 'Kategori', 'url' => route('categories.index')], ['label' => 'Tambah']]" />
@include('pages.categories._form')
@endsection
