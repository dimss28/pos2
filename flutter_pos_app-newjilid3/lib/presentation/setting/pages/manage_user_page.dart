import 'package:flutter/material.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/user_remote_datasource.dart';
import '../../../data/models/response/user_model.dart';

/// Kelola Karyawan — admin/owner only.
/// Backend gated via UserPolicy.
class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final _ds = UserRemoteDatasource();
  List<UserModel>? _items;
  String? _error;
  bool _loading = false;
  String? _roleFilter;

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
    final result = await _ds.list(role: _roleFilter);
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

  Future<void> _delete(UserModel u) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna?'),
        content: Text(
          '"${u.name}" akan dihapus (soft delete). Data order tetap utuh.',
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
    final result = await _ds.delete(u.id);
    if (!mounted) return;
    result.fold(
      (err) => AppSnackbar.error(context, err),
      (_) {
        AppSnackbar.success(context, 'Pengguna dihapus');
        _load();
      },
    );
  }

  Future<void> _openSheet({UserModel? edit}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _UserFormSheet(existing: edit, datasource: _ds),
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
        title: 'Kelola Karyawan',
        subtitle: 'Tambah / atur akun kasir, admin, owner',
      ),
      body: Column(
        children: [
          _RoleFilterBar(
            selected: _roleFilter,
            onChanged: (v) {
              setState(() => _roleFilter = v);
              _load();
            },
          ),
          Expanded(child: _buildBody(p)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        icon: const Icon(Icons.person_add),
        label: const Text('Karyawan'),
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
        child: AppEmptyState.error(message: _error!, onRetry: _load),
      );
    }
    final items = _items ?? const <UserModel>[];
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppEmptyState(
          title: 'Belum ada karyawan',
          body: 'Tambah karyawan pertama untuk mulai mengelola tim.',
          primaryAction: AppButton(
            label: 'Tambah karyawan',
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
          final u = items[i];
          return _UserTile(
            user: u,
            onTap: () => _openSheet(edit: u),
            onDelete: () => _delete(u),
          );
        },
      ),
    );
  }
}

class _RoleFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _RoleFilterBar({required this.selected, required this.onChanged});

  static const _roles = [
    [null, 'Semua'],
    ['owner', 'Pemilik'],
    ['admin', 'Admin'],
    ['kasir', 'Kasir'],
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: p.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _roles.map((r) {
            final isSelected = selected == r[0];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(r[1]!),
                selected: isSelected,
                onSelected: (_) => onChanged(r[0] as String?),
                selectedColor: p.primary,
                labelStyle: TextStyle(
                  color: isSelected ? p.onPrimary : p.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _UserTile({
    required this.user,
    required this.onTap,
    required this.onDelete,
  });

  Color _roleColor(BuildContext ctx, String role) {
    switch (role) {
      case 'owner':
        return Colors.red.shade400;
      case 'admin':
        return Colors.blue.shade400;
      default:
        return Colors.teal.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final roleColor = _roleColor(context, user.roles);
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
              CircleAvatar(
                radius: 22,
                backgroundColor: roleColor.withValues(alpha: 0.15),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : '?',
                        style:
                            TextStyle(color: roleColor, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: AppTypography.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!user.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: p.outlineSoft,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text('Nonaktif',
                                style: AppTypography.bodyS),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user.email, style: AppTypography.bodyS),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        user.roleLabel,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
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

class _UserFormSheet extends StatefulWidget {
  final UserModel? existing;
  final UserRemoteDatasource datasource;
  const _UserFormSheet({required this.existing, required this.datasource});

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _password;
  late String _role;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _email = TextEditingController(text: widget.existing?.email ?? '');
    _phone = TextEditingController(text: widget.existing?.phone ?? '');
    _password = TextEditingController();
    _role = widget.existing?.roles ?? 'kasir';
    _isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 2) {
      AppSnackbar.error(context, 'Nama minimal 2 karakter');
      return;
    }
    if (!_email.text.contains('@')) {
      AppSnackbar.error(context, 'Email tidak valid');
      return;
    }
    final isCreate = widget.existing == null;
    if (isCreate && _password.text.length < 8) {
      AppSnackbar.error(context, 'Password minimal 8 karakter');
      return;
    }
    if (!isCreate &&
        _password.text.isNotEmpty &&
        _password.text.length < 8) {
      AppSnackbar.error(context, 'Password minimal 8 karakter');
      return;
    }

    setState(() => _saving = true);
    final result = isCreate
        ? await widget.datasource.create(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            roles: _role,
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            isActive: _isActive,
          )
        : await widget.datasource.update(
            id: widget.existing!.id,
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            password: _password.text.isEmpty ? null : _password.text,
            roles: _role,
            isActive: _isActive,
          );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (err) => AppSnackbar.error(context, err),
      (_) {
        AppSnackbar.success(
          context,
          isCreate ? 'Karyawan dibuat' : 'Karyawan diperbarui',
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isCreate = widget.existing == null;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                isCreate ? 'Tambah Karyawan' : 'Edit Karyawan',
                style: AppTypography.titleM,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Nama Lengkap',
                hint: 'cth: Andi Pratama',
                controller: _name,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email',
                hint: 'cth: andi@cafe.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'No. HP (opsional)',
                hint: 'cth: 0812-3456-7890',
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: isCreate
                    ? 'Password (min 8 karakter)'
                    : 'Password (kosongkan kalau tidak diubah)',
                hint: '••••••••',
                controller: _password,
                obscure: true,
              ),
              const SizedBox(height: 16),
              Text('Role', style: AppTypography.labelL),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in [
                    ['kasir', 'Kasir'],
                    ['admin', 'Admin'],
                    ['owner', 'Pemilik'],
                  ])
                    ChoiceChip(
                      label: Text(r[1]),
                      selected: _role == r[0],
                      onSelected: (_) => setState(() => _role = r[0]),
                      selectedColor: p.primary,
                      labelStyle: TextStyle(
                        color: _role == r[0] ? p.onPrimary : p.onSurface,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aktif'),
                subtitle: Text(
                  _isActive ? 'Bisa login' : 'Tidak bisa login',
                  style: AppTypography.bodyS,
                ),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: isCreate ? 'Simpan' : 'Perbarui',
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
