@extends('layouts.app')
@section('title', __('Edit Pengguna'))
@section('page-title', __('Edit Pengguna'))
@section('main')
<x-page-header :title="'Edit: ' . $user->name"
    :breadcrumbs="[['label' => 'Pengguna', 'url' => route('user.index')], ['label' => 'Edit']]" />
@include('pages.users._form')
@endsection
