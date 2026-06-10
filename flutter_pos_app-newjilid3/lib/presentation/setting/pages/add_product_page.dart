import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_money_text_field.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_stepper_field.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/app_switch_tile.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/response/category_response_model.dart';
import '../../../data/models/response/product_response_model.dart';
import '../../home/bloc/category/category_bloc.dart';
import '../../home/bloc/product/product_bloc.dart';

class AddProductPage extends StatefulWidget {
  /// When non-null the form operates in edit mode: pre-filled fields and the
  /// submit hits `PUT /products/{id}` instead of `POST /products`. Image
  /// becomes optional (keep existing if not re-picked).
  final Product? existing;

  const AddProductPage({super.key, this.existing});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameCtrl = TextEditingController();
  int _price = 0;
  int _stock = 0;
  Category? _category;
  XFile? _imageFile;
  bool _bestSeller = false;
  String? _nameError;
  String? _categoryError;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _price = e.price;
      _stock = e.stock;
      _bestSeller = e.isBestSeller;
      // Category is hydrated once CategoryBloc has loaded; see _CategoryDropdown.
      _category = Category(id: e.categoryId, name: e.category);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Android 13+ uses Permission.photos (READ_MEDIA_IMAGES); 12 and below
    // route via Permission.storage. image_picker handles this internally on
    // some plugin versions, but doing the request here lets us surface a
    // clear denial message instead of a silent no-op.
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (!mounted) return;
      AppSnackbar.error(
          context, 'Izin galeri ditolak. Aktifkan di Pengaturan.');
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (picked == null || !mounted) return;
    setState(() => _imageFile = picked);
  }

  void _submit() {
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? 'Nama wajib diisi' : null;
      _categoryError = _category == null ? 'Pilih kategori' : null;
    });
    if (_nameError != null || _categoryError != null) return;
    // Image required on create, optional on edit (keep existing if unchanged).
    if (!_isEdit && _imageFile == null) {
      AppSnackbar.error(context, 'Pilih foto produk dulu');
      return;
    }
    final draft = Product(
      id: widget.existing?.id,
      productId: widget.existing?.productId,
      name: _nameCtrl.text.trim(),
      price: _price,
      stock: _stock,
      category: _category!.name,
      categoryId: _category!.id,
      isBestSeller: _bestSeller,
      image: _imageFile?.path ?? widget.existing?.image ?? '',
    );
    if (_isEdit) {
      // `Product.productId` holds the BE primary key (stored on local rows
      // as `product_id`). `Product.id` is the local SQLite autoincrement
      // and would 404 when sent to BE. Fall back to id only for products
      // created locally before a sync round-trip.
      final beId = widget.existing!.productId ?? widget.existing!.id;
      if (beId == null) {
        AppSnackbar.error(
          context,
          'Produk ini belum tersinkron ke server. Sinkronkan dulu sebelum edit.',
        );
        return;
      }
      context.read<ProductBloc>().add(
            ProductEvent.updateProduct(
              productId: beId,
              product: draft,
              image: _imageFile,
            ),
          );
    } else {
      context
          .read<ProductBloc>()
          .add(ProductEvent.addProduct(draft, _imageFile!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: _isEdit ? 'Edit Produk' : 'Tambah Produk',
        subtitle: _isEdit
            ? 'Ubah detail produk yang sudah ada'
            : 'Lengkapi info menu baru',
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          state.maybeMap(
            orElse: () {},
            success: (_) {
              AppSnackbar.success(
                context,
                _isEdit ? 'Produk diperbarui' : 'Produk tersimpan',
              );
              Navigator.of(context).maybePop();
            },
            error: (e) => AppSnackbar.error(context, e.message),
          );
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _PhotoPicker(
                file: _imageFile,
                existingUrl: widget.existing?.displayImageUrl,
                onTap: _pickImage,
              ),
              const AppSectionLabel('Informasi'),
              AppTextField(
                label: 'Nama Produk',
                hint: 'cth. Kopi Susu Gula Aren',
                controller: _nameCtrl,
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: 14),
              AppMoneyTextField(
                label: 'Harga',
                initialValue: _price,
                onChanged: (v) => setState(() => _price = v),
              ),
              const AppSectionLabel('Kategori'),
              _CategoryDropdown(
                value: _category,
                error: _categoryError,
                onChanged: (c) {
                  setState(() {
                    _category = c;
                    _categoryError = null;
                  });
                },
              ),
              const AppSectionLabel('Stok'),
              AppStepperField(
                value: _stock,
                onChanged: (v) => setState(() => _stock = v),
              ),
              const AppSectionLabel('Tampilan'),
              AppCard(
                padding: EdgeInsets.zero,
                child: AppSwitchTile(
                  title: 'Tandai sebagai Bestseller',
                  subtitle: 'Akan muncul di strip menu favorit',
                  value: _bestSeller,
                  onChanged: (v) => setState(() => _bestSeller = v),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppStickyFooter(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            final loading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            return AppButton(
              label: _isEdit ? 'Simpan Perubahan' : 'Simpan Produk',
              loading: loading,
              onPressed: loading ? null : _submit,
            );
          },
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final XFile? file;
  final String? existingUrl;
  final VoidCallback onTap;
  const _PhotoPicker({
    required this.file,
    this.existingUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasFile = file != null;
    final hasExisting =
        existingUrl != null && existingUrl!.isNotEmpty && !hasFile;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: p.surfaceVariant,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: p.outline,
              style: BorderStyle.solid,
              width: 1.5,
            ),
          ),
          child: hasFile
              ? ClipRRect(
                  borderRadius: AppRadius.mdAll,
                  child: Image.file(
                    File(file!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : hasExisting
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: AppRadius.mdAll,
                            child: Image.network(
                              existingUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.camera_alt_outlined,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Ganti foto',
                                  style: AppTypography.bodyS.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: p.primary, size: 32),
                        const SizedBox(height: 8),
                        Text('Tap untuk pilih foto',
                            style: AppTypography.bodyM
                                .copyWith(color: p.onSurface)),
                        const SizedBox(height: 2),
                        Text('PNG / JPG · maks. 2 MB',
                            style: AppTypography.bodyS.copyWith(
                                color: p.onSurfaceVar, fontSize: 11)),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final Category? value;
  final String? error;
  final ValueChanged<Category?> onChanged;
  const _CategoryDropdown({
    required this.value,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state.maybeWhen(
          loaded: (list) => list,
          loadedLocal: (list) => list,
          orElse: () => const <Category>[],
        );
        // Resolve the current value to the matching item from the loaded
        // list — DropdownButton requires the value to be `==` one of the
        // items, and Category has no custom equality, so a Category we
        // built in initState (edit mode) won't match by identity.
        Category? resolvedValue;
        if (value != null) {
          for (final c in categories) {
            if (c.id == value!.id) {
              resolvedValue = c;
              break;
            }
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: error != null ? p.error : p.outline,
                  width: 1.5,
                ),
              ),
              child: DropdownButton<Category>(
                value: resolvedValue,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                hint: Text(
                  'Pilih kategori',
                  style: AppTypography.bodyL
                      .copyWith(color: p.onSurfaceVar),
                ),
                icon: Icon(Icons.expand_more, color: p.onSurfaceVar),
                items: [
                  for (final c in categories)
                    DropdownMenuItem(value: c, child: Text(c.name)),
                ],
                onChanged: onChanged,
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(left: 2, top: 6),
                child: Text(
                  error!,
                  style: AppTypography.bodyS.copyWith(
                    color: p.error,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
