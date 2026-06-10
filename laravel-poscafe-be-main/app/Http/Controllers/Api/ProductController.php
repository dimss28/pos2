<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Http\Responses\ApiResponse;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with('category:id,name');
        if ($request->filled('q')) $query->where('name', 'like', '%'.$request->q.'%');
        if ($request->filled('category_id')) $query->where('category_id', $request->category_id);

        return ProductResource::collection($query->paginate(50));
    }

    public function show(Product $product)
    {
        return ApiResponse::success(new ProductResource($product->load('category')));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'integer', 'min:0'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'category_id' => ['required', 'exists:categories,id'],
            'image' => ['nullable', 'image', 'max:2048'],
            'is_best_seller' => ['nullable', 'boolean'],
        ]);

        if ($request->hasFile('image')) {
            $data['image'] = basename($request->file('image')->store('products', 'public'));
        }
        $data['category'] = Category::find($data['category_id'])->name ?? 'food';
        $product = Product::create($data);

        return ApiResponse::success(new ProductResource($product), 'Produk dibuat.', 201);
    }

    public function update(Request $request, Product $product)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'price' => ['sometimes', 'integer', 'min:0'],
            'stock' => ['sometimes', 'integer', 'min:0'],
            'category_id' => ['sometimes', 'exists:categories,id'],
            'image' => ['nullable', 'image', 'max:2048'],
            'is_best_seller' => ['nullable', 'boolean'],
        ]);

        if ($request->hasFile('image')) {
            if ($product->image) Storage::disk('public')->delete('products/'.$product->image);
            $data['image'] = basename($request->file('image')->store('products', 'public'));
        }
        $product->update($data);

        return ApiResponse::success(new ProductResource($product->fresh()));
    }
}
