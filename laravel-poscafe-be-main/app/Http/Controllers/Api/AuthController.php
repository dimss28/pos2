<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string'],
        ]);

        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        if (array_key_exists('is_active', $user->getAttributes()) && $user->is_active === false) {
            return ApiResponse::error('Akun nonaktif.', 403);
        }

        if (Schema::hasColumn('users', 'last_login_at')) {
            $user->forceFill([
                'last_login_at' => now(),
                'last_login_ip' => $request->ip(),
            ])->saveQuietly();
        }

        $token = $user->createToken($data['device_name'] ?? 'mobile')->plainTextToken;

        return ApiResponse::success([
            'user' => new UserResource($user),
            'token' => $token,
        ], 'Login berhasil.');
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return ApiResponse::success(null, 'Logout berhasil.');
    }

    public function me(Request $request)
    {
        return ApiResponse::success(new UserResource($request->user()));
    }

    public function deleteAccount(Request $request)
    {
        $request->validate([
            'confirmation' => ['required', 'in:HAPUS AKUN'],
            'password' => ['required', 'current_password'],
        ]);

        $user = $request->user();

        if ($user->isOwner() && User::where('roles', 'owner')->where('id', '!=', $user->id)->count() === 0) {
            return ApiResponse::error('Tidak bisa menghapus owner terakhir.', 422);
        }

        DB::transaction(function () use ($user) {
            $user->forceFill([
                'name' => '[akun dihapus]',
                'email' => 'deleted-'.$user->id.'@deleted.local',
                'avatar' => null,
                'phone' => null,
                'is_active' => false,
            ])->saveQuietly();
            $user->tokens()->delete();
            $user->delete();
        });

        return ApiResponse::success(null, 'Akun dihapus.');
    }
}
