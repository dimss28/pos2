@extends('layouts.app')
@section('title', 'Tambah Meja')
@section('page-title', 'Tambah Meja')
@section('main')
<x-page-header title="Tambah Meja" :breadcrumbs="[['label' => 'Meja', 'url' => route('dining-table.index')], ['label' => 'Tambah']]" />
@include('pages.dining-tables._form', ['action' => route('dining-table.store'), 'table' => new App\Models\DiningTable()])
@endsection
