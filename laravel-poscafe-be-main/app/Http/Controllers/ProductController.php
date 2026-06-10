<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductStoreRequest;
use App\Http\Requests\ProductUpdateRequest;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $this->authorize('viewAny', Product::class);

        $query = Product::query();

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->q.'%');
        }
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }
        if ($request->stock_filter === 'low') {
            $query->whereBetween('stock', [1, 4]);
        }
        if ($request->stock_filter === 'out') {
            $query->where('stock', 0);
        }

        $sort = $request->get('sort', 'created_at');
        $direction = $request->get('direction', 'desc');
        if (in_array($sort, ['name', 'price', 'stock', 'created_at'])) {
            $query->orderBy($sort, $direction === 'asc' ? 'asc' : 'desc');
        }

        $products = $query->paginate(15)->withQueryString();
        $categories = Category::orderBy('name')->get(['id', 'name']);

        return view('pages.products.index', compact('products', 'categories', 'sort', 'direction'));
    }

    public function create()
    {
        $this->authorize('create', Product::class);
        $product = new Product(['is_best_seller' => false]);
        $categories = Category::orderBy('name')->get(['id', 'name']);

        return view('pages.products.create', compact('product', 'categories'));
    }

    public function store(ProductStoreRequest $request)
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('products', 'public');
            $data['image'] = basename($path);
        }

        $data['category'] = optional(Category::find($data['category_id']))->name ?? 'food';

        Product::create($data);

        if ($request->has('save_and_new')) {
            return redirect()->route('product.create')->with('success', __('Produk ditambahkan. Tambah produk lain?'));
        }

        return redirect()->route('product.index')->with('success', __('messages.created', ['resource' => 'Produk']));
    }

    public function show(Product $product)
    {
        $this->authorize('view', $product);

        return redirect()->route('product.edit', $product);
    }

    public function edit(Product $product)
    {
        $this->authorize('update', $product);
        $categories = Category::orderBy('name')->get(['id', 'name']);

        return view('pages.products.edit', compact('product', 'categories'));
    }

    public function update(ProductUpdateRequest $request, Product $product)
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $product->deleteStoredImage();
            $path = $request->file('image')->store('products', 'public');
            $data['image'] = basename($path);
        }

        $data['category'] = optional(Category::find($data['category_id']))->name ?? $product->category;
        $product->update($data);

        return redirect()->route('product.index')->with('success', __('messages.updated', ['resource' => 'Produk']));
    }

    public function destroy(Product $product)
    {
        $this->authorize('delete', $product);

        $product->deleteStoredImage();
        $product->delete();

        return back()->with('success', __('messages.deleted', ['resource' => 'Produk']));
    }

    public function bulkDestroy(Request $request)
    {
        $ids = $request->validate([
            'ids' => 'required|array',
            'ids.*' => 'integer',
        ])['ids'];

        $products = Product::whereIn('id', $ids)->get();
        foreach ($products as $p) {
            $this->authorize('delete', $p);
            $p->deleteStoredImage();
        }
        Product::whereIn('id', $ids)->delete();

        return back()->with('success', count($ids).' produk dihapus.');
    }
}
