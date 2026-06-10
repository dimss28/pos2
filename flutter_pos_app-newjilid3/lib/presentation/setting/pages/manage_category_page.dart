import 'package:flutter/material.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/category_remote_datasource.dart';
import '../../../data/models/response/category_response_model.dart';

/// Kelola Kategori — admin/owner only.
/// Kasir akan dapat 403 dari backend (CategoryPolicy::create/update/delete).
class ManageCategoryPage extends StatefulWidget {
  const ManageCategoryPage({super.key});

  @override
  State<ManageCategoryPage> createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends State<ManageCategoryPage> {
  final _ds = CategoryRemoteDatasource();
  List<Category>? _items;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _ds.list();
    if (!mounted) return;
    result.fold(
      (err) => setState(() {
        _error = err;
        _loading = false;
      }),
      (list) => setState(() {
        _items = list;
        _loading = false;
      }),
    );
  }

  Future<void> _delete(Category cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text(
          '"${cat.name}" akan dihapus. Aksi ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await _ds.delete(cat.id);
    if (!mounted) return;
    result.fold(
      (err) => AppSnackbar.error(context, err),
      (_) {
        AppSnackbar.success(context, 'Kategori dihapus');
        _load();
      },
    );
  }

  Future<void> _openSheet({Category? edit}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _CategoryFormSheet(
          existing: edit,
          datasource: _ds,
        ),
      ),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Kelola Kategori',
        subtitle: 'Tambah, ubah, atau hapus kategori menu',
      ),
      body: _buildBody(p),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Kategori'),
      ),
    );
  }

  Widget _buildBody(AppPalette p) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: p.primary));
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppEmptyState.error(
          message: _error!,
          onRetry: _load,
        ),
      );
    }
    final items = _items ?? const <Category>[];
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppEmptyState(
          title: 'Belum ada kategori',
          body:
              'Tambah kategori pertama untuk mulai mengelompokkan produk.',
          primaryAction: AppButton(
            label: 'Tambah kategori',
            onPressed: () => _openSheet(),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final cat = items[i];
          return _CategoryTile(
            category: cat,
            onTap: () => _openSheet(edit: cat),
            onDelete: () => _delete(cat),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  Color _parseColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = _parseColor(category.color);
    return Material(
      color: p.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.label, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category.name,
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!category.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.outlineSoft,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              'Nonaktif',
                              style: AppTypography.labelL,
                            ),
                          ),
                      ],
                    ),
                    if (category.productsCount != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${category.productsCount} produk',
                          style: AppTypography.bodyS,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  final Category? existing;
  final CategoryRemoteDatasource datasource;
  const _CategoryFormSheet({
    required this.existing,
    required this.datasource,
  });

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late String _color;
  late bool _isActive;
  bool _saving = false;

  static const _palette = [
    '#3B82F6',
    '#10B981',
    '#F59E0B',
    '#EF4444',
    '#8B5CF6',
    '#EC4899',
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _desc =
        TextEditingController(text: widget.existing?.description ?? '');
    _color = widget.existing?.color ?? _palette.first;
    _isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 2) {
      AppSnackbar.error(context, 'Nama kategori minimal 2 karakter');
      return;
    }
    setState(() => _saving = true);
    final result = widget.existing == null
        ? await widget.datasource.create(
            name: _name.text.trim(),
            description:
                _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            color: _color,
            isActive: _isActive,
          )
        : await widget.datasource.update(
            id: widget.existing!.id,
            name: _name.text.trim(),
            description:
                _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            color: _color,
            isActive: _isActive,
          );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (err) => AppSnackbar.error(context, err),
      (_) {
        AppSnackbar.success(
          context,
          widget.existing == null ? 'Kategori dibuat' : 'Kategori diperbarui',
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: p.outlineSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing == null ? 'Tambah Kategori' : 'Edit Kategori',
              style: AppTypography.titleM,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Nama Kategori',
              hint: 'cth: Minuman Dingin',
              controller: _name,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Deskripsi (opsional)',
              hint: 'Catatan singkat tentang kategori',
              controller: _desc,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Text('Warna', style: AppTypography.labelL),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _palette.map((c) {
                final color = _parseColor(c);
                final selected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? p.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aktif'),
              subtitle: Text(
                _isActive ? 'Tampil di list pilihan kasir' : 'Tersembunyi',
                style: AppTypography.bodyS,
              ),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: widget.existing == null ? 'Simpan' : 'Perbarui',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
