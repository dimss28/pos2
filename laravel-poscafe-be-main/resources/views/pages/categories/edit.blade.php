@extends('layouts.app')
@section('title', __('Edit Kategori'))
@section('page-title', __('Edit Kategori'))
@section('main')
<x-page-header :title="'Edit: ' . $category->name"
    :breadcrumbs="[['label' => 'Kategori', 'url' => route('categories.index')], ['label' => 'Edit']]" />
@include('pages.categories._form')
@endsection
