import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/feedback.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/cash_session_remote_datasource.dart';
import '../../../data/models/response/cash_session_model.dart';

/// Admin/owner page: lihat semua shift yang masih terbuka di seluruh
/// kasir, dengan opsi force-close.
///
/// Use case: kasir lupa tutup shift sebelum pulang → admin force-close
/// agar dashboard / variance tetap akurat untuk hari berikutnya. Audit
/// trail disimpan di `closing_note` ("[Force-closed oleh {nama admin}]").
class AdminShiftPage extends StatefulWidget {
  const AdminShiftPage({super.key});

  @override
  State<AdminShiftPage> createState() => _AdminShiftPageState();
}

class _AdminShiftPageState extends State<AdminShiftPage> {
  final _ds = CashSessionRemoteDatasource();
  List<CashSessionModel>? _items;
  String? _error;
  bool _loading = false;
  String _statusFilter = 'open';

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
    final result = await _ds.list(all: true, status: _statusFilter);
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

  Future<void> _forceClose(CashSessionModel session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Force-close shift?'),
        content: Text(
          'Shift ${session.shiftLabel} milik ${session.userName} akan '
          'ditutup paksa dengan variance 0. Note akan di-tag dengan nama Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Force Close'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || session.id == null) return;

    final result = await _ds.forceClose(session.id!);
    if (!mounted) return;
    result.fold(
      (err) => AppSnackbar.error(context, err),
      (_) {
        AppSnackbar.success(context, 'Shift di-force close');
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Kelola Shift',
        subtitle: 'Lihat & force-close shift kasir lain',
      ),
      body: Column(
        children: [
          _StatusFilterBar(
            value: _statusFilter,
            onChanged: (v) {
              setState(() => _statusFilter = v);
              _load();
            },
          ),
          Expanded(child: _buildBody(p)),
        ],
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
    final items = _items ?? const <CashSessionModel>[];
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppEmptyState(
          title: _statusFilter == 'open'
              ? 'Tidak ada shift terbuka'
              : 'Belum ada riwayat shift',
          body: _statusFilter == 'open'
              ? 'Semua kasir sudah menutup shift. Tidak perlu force-close.'
              : null,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final s = items[i];
          return _ShiftTile(
            session: s,
            isOpen: _statusFilter == 'open',
            onForceClose: () => _forceClose(s),
          );
        },
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _StatusFilterBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: p.surface,
      child: Row(
        children: [
          for (final r in [
            ['open', 'Terbuka'],
            ['closed', 'Tutup'],
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(r[1]),
                selected: value == r[0],
                onSelected: (_) => onChanged(r[0]),
                selectedColor: p.primary,
                labelStyle: TextStyle(
                  color: value == r[0] ? p.onPrimary : p.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShiftTile extends StatelessWidget {
  final CashSessionModel session;
  final bool isOpen;
  final VoidCallback onForceClose;
  const _ShiftTile({
    required this.session,
    required this.isOpen,
    required this.onForceClose,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final df = DateFormat('d MMM yyyy, HH:mm', 'id');
    return Material(
      color: p.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isOpen ? Colors.green : Colors.grey)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    session.shiftLabel,
                    style: TextStyle(
                      color: isOpen
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.userName,
                    style: AppTypography.bodyM
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuka: ${df.format(session.openedAt)}',
              style: AppTypography.bodyS,
            ),
            if (session.closedAt != null)
              Text(
                'Ditutup: ${df.format(session.closedAt!)}',
                style: AppTypography.bodyS,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Modal awal: ',
                  style: AppTypography.bodyS,
                ),
                Text(
                  session.openingFloat.currencyFormatRp,
                  style: AppTypography.bodyS
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 12),
              AppButton.outline(
                label: 'Force Close',
                leadingIcon: Icons.lock_clock,
                onPressed: onForceClose,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
