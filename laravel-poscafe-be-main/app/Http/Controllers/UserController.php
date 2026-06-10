<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateUserRequest;
use App\Http\Requests\UserStoreRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', User::class);

        $query = User::query();
        if ($request->filled('q')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', '%'.$request->q.'%')
                  ->orWhere('email', 'like', '%'.$request->q.'%');
            });
        }
        if ($request->filled('role')) {
            $query->where('roles', $request->role);
        }

        $users = $query->latest()->paginate(15)->withQueryString();

        return view('pages.users.index', compact('users'));
    }

    public function create()
    {
        $this->authorize('create', User::class);

        return view('pages.users.create', [
            'user' => new User(['is_active' => true, 'roles' => 'kasir']),
        ]);
    }

    public function store(UserStoreRequest $request)
    {
        $data = $request->validated();
        if ($request->hasFile('avatar')) {
            $data['avatar'] = basename($request->file('avatar')->store('avatars', 'public'));
        }
        unset($data['password_confirmation']);
        User::create($data);

        return redirect()->route('user.index')->with('success', __('messages.created', ['resource' => 'Pengguna']));
    }

    public function show(User $user)
    {
        $this->authorize('view', $user);

        return redirect()->route('user.edit', $user);
    }

    public function edit(User $user)
    {
        $this->authorize('update', $user);

        return view('pages.users.edit', compact('user'));
    }

    public function update(UpdateUserRequest $request, User $user)
    {
        $data = $request->validated();
        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                Storage::disk('public')->delete('avatars/'.$user->avatar);
            }
            $data['avatar'] = basename($request->file('avatar')->store('avatars', 'public'));
        }
        if (empty($data['password'])) {
            unset($data['password']);
        }
        unset($data['password_confirmation']);
        $user->update($data);

        return redirect()->route('user.index')->with('success', __('messages.updated', ['resource' => 'Pengguna']));
    }

    public function destroy(User $user)
    {
        $this->authorize('delete', $user);

        if ($user->id === auth()->id()) {
            return back()->with('error', __('Tidak bisa menghapus akun sendiri.'));
        }
        if ($user->avatar) {
            Storage::disk('public')->delete('avatars/'.$user->avatar);
        }
        $user->delete();

        return back()->with('success', __('messages.deleted', ['resource' => 'Pengguna']));
    }
}
