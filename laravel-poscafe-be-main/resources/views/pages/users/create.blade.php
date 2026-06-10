@extends('layouts.app')
@section('title', __('Tambah Pengguna'))
@section('page-title', __('Tambah Pengguna'))
@section('main')
<x-page-header title="Tambah Pengguna"
    :breadcrumbs="[['label' => 'Pengguna', 'url' => route('user.index')], ['label' => 'Tambah']]" />
@include('pages.users._form')
@endsection
