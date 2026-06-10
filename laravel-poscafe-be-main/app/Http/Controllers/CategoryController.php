<?php

namespace App\Http\Controllers;

use App\Http\Requests\CategoryRequest;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Category::class);
        $view = $request->get('view', 'grid');
        $query = Category::withCount('products');

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->q.'%');
        }

        $categories = $query->orderBy('sort_order')->orderBy('name')->paginate(20)->withQueryString();

        return view('pages.categories.index', compact('categories', 'view'));
    }

    public function create()
    {
        $this->authorize('create', Category::class);
        $category = new Category(['icon' => 'tag', 'color' => '#3B82F6', 'is_active' => true]);

        return view('pages.categories.create', compact('category'));
    }

    public function store(CategoryRequest $request)
    {
        $this->authorize('create', Category::class);
        Category::create($request->validated());

        return redirect()->route('categories.index')
            ->with('success', __('messages.created', ['resource' => 'Kategori']));
    }

    public function show(Category $category)
    {
        return redirect()->route('categories.edit', $category);
    }

    public function edit(Category $category)
    {
        $this->authorize('update', $category);

        return view('pages.categories.edit', compact('category'));
    }

    public function update(CategoryRequest $request, Category $category)
    {
        $this->authorize('update', $category);
        $category->update($request->validated());

        return redirect()->route('categories.index')
            ->with('success', __('messages.updated', ['resource' => 'Kategori']));
    }

    public function destroy(Category $category)
    {
        $this->authorize('delete', $category);
        if ($category->products()->exists()) {
            return back()->with('error', __('Kategori tidak bisa dihapus karena masih memiliki produk.'));
        }

        $category->delete();

        return back()->with('success', __('messages.deleted', ['resource' => 'Kategori']));
    }
}
