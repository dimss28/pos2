<?php

if (! function_exists('rupiah')) {
    function rupiah(int|float|null $amount, bool $withPrefix = true): string
    {
        $formatted = number_format((float) ($amount ?? 0), 0, ',', '.');

        return $withPrefix ? 'Rp '.$formatted : $formatted;
    }
}

if (! function_exists('formatDate')) {
    function formatDate(mixed $value, string $format = 'd M Y H:i', string $fallback = '—'): string
    {
        if (empty($value)) {
            return $fallback;
        }
        try {
            return \Carbon\Carbon::parse($value)->translatedFormat($format);
        } catch (\Throwable) {
            return $fallback;
        }
    }
}

if (! function_exists('initials')) {
    function initials(?string $name): string
    {
        if (empty($name)) {
            return '?';
        }
        $parts = preg_split('/\s+/', trim($name));
        if (count($parts) >= 2) {
            return strtoupper(mb_substr($parts[0], 0, 1).mb_substr(end($parts), 0, 1));
        }

        return strtoupper(mb_substr($parts[0], 0, 2));
    }
}
