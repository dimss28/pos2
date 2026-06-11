<?php

use App\Models\StoreSetting;

if (! function_exists('store_name')) {
    function store_name(): string
    {
        try {
            return StoreSetting::get('store_name') ?: (string) config('app.name');
        } catch (\Throwable) {
            return (string) config('app.name');
        }
    }
}

if (! function_exists('store_tagline')) {
    function store_tagline(): string
    {
        try {
            return (string) (StoreSetting::get('store_tagline') ?? '');
        } catch (\Throwable) {
            return '';
        }
    }
}
