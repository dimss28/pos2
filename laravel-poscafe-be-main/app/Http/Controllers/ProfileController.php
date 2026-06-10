<?php

namespace App\Http\Controllers;

use App\Models\CashSession;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    public function show()
    {
        return view('pages.profile.index', ['user' => auth()->user()]);
    }

    public function update(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:100'],
            'email' => ['required', 'email', Rule::unique('users', 'email')->ignore($user->id)],
            'phone' => ['nullable', 'string', 'max:30'],
            'avatar' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:1024'],
        ]);

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                Storage::disk('public')->delete('avatars/'.$user->avatar);
            }
            $data['avatar'] = basename($request->file('avatar')->store('avatars', 'public'));
        }
        $user->update($data);

        return back()->with('success', __('Profil berhasil diperbarui.'));
    }

    public function updatePassword(Request $request)
    {
        $request->validate([
            'current_password' => ['required', 'current_password'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);
        $request->user()->update(['password' => $request->password]);

        return back()->with('success', __('Password berhasil diubah.'));
    }

    public function destroy(Request $request)
    {
        $request->validate([
            'confirmation' => ['required', 'in:HAPUS AKUN'],
            'password' => ['required', 'current_password'],
        ]);
        $user = $request->user();

        if ($user->isOwner() && User::where('roles', 'owner')->where('id', '!=', $user->id)->count() === 0) {
            return back()->with('error', __('Tidak bisa menghapus owner terakhir.'));
        }

        if (CashSession::open()->forUser($user->id)->exists()) {
            return back()->with('error', __('Tutup shift Anda terlebih dahulu sebelum menghapus akun.'));
        }

        DB::transaction(function () use ($user) {
            $user->forceFill([
                'name' => '[akun dihapus]',
                'email' => 'deleted-'.$user->id.'@deleted.local',
                'phone' => null,
                'avatar' => null,
                'is_active' => false,
            ])->saveQuietly();
            $user->tokens()->delete();
            $user->delete();
        });

        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login')->with('status', __('Akun Anda telah dihapus.'));
    }
}
