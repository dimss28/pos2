<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\EnsureUserHasRole::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $guestJson = fn (Request $request) => $request->is('api/*')
            || $request->is('m/*')
            || $request->expectsJson();

        $exceptions->shouldRenderJsonWhen($guestJson);

        $exceptions->render(function (\Illuminate\Validation\ValidationException $e, Request $request) use ($guestJson) {
            if (! $guestJson($request)) {
                return null;
            }
            if ($request->is('api/*')) {
                return \App\Http\Responses\ApiResponse::error('Validasi gagal', 422, $e->errors());
            }

            return response()->json([
                'message' => collect($e->errors())->flatten()->first() ?? 'Validasi gagal.',
                'errors' => $e->errors(),
            ], 422);
        });
        $exceptions->render(function (\Illuminate\Auth\AuthenticationException $e, Request $request) use ($guestJson) {
            if ($guestJson($request)) {
                return $request->is('api/*')
                    ? \App\Http\Responses\ApiResponse::error('Unauthenticated', 401)
                    : response()->json(['message' => 'Unauthenticated'], 401);
            }
        });
        $exceptions->render(function (\Illuminate\Database\Eloquent\ModelNotFoundException $e, Request $request) use ($guestJson) {
            if ($guestJson($request)) {
                return $request->is('api/*')
                    ? \App\Http\Responses\ApiResponse::error('Resource tidak ditemukan', 404)
                    : response()->json(['message' => 'Resource tidak ditemukan'], 404);
            }
        });
        $exceptions->render(function (\Illuminate\Session\TokenMismatchException $e, Request $request) use ($guestJson) {
            if ($guestJson($request)) {
                return response()->json([
                    'message' => 'Sesi habis. Muat ulang halaman lalu coba lagi.',
                ], 419);
            }
        });
    })->create();
