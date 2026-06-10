import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_numbered_step.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../order/models/draft_order_model.dart';
import '../bloc/draft_order/draft_order_bloc.dart';
import '../widgets/draft_order_card.dart';

class DraftOrderPage extends StatefulWidget {
  const DraftOrderPage({super.key});

  @override
  State<DraftOrderPage> createState() => _DraftOrderPageState();
}

class _DraftOrderPageState extends State<DraftOrderPage> {
  final _searchCtrl = TextEditingController();
  int? _expandedId;
  String _query = '';

  @override
  void initState() {
    super.initState();
    context
        .read<DraftOrderBloc>()
        .add(const DraftOrderEvent.getAllDraftOrder());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DraftOrderModel> _filter(List<DraftOrderModel> drafts) {
    if (_query.trim().isEmpty) return drafts;
    final q = _query.toLowerCase();
    return drafts.where((d) {
      return d.displayTableLabel.toLowerCase().contains(q) ||
          d.displayCustomerName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Open Bill',
        subtitle: 'Pesanan yang ditunda pembayarannya',
      ),
      body: BlocBuilder<DraftOrderBloc, DraftOrderState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () =>
                Center(child: CircularProgressIndicator(color: p.primary)),
            error: (msg) => Center(
              child: AppEmptyState.error(
                message: msg,
                onRetry: () => context
                    .read<DraftOrderBloc>()
                    .add(const DraftOrderEvent.getAllDraftOrder()),
              ),
            ),
            success: (drafts) {
              if (drafts.isEmpty) return const _EmptyDrafts();
              final filtered = _filter(drafts);
              final total = drafts.fold<int>(0, (s, d) => s + d.totalPrice);
              return Column(
                children: [
                  _SearchBar(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  _SummaryChip(total: total, count: drafts.length),
                  Expanded(
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) => DraftOrderCard(
                        data: filtered[i],
                        expanded: filtered[i].id != null &&
                            _expandedId == filtered[i].id,
                        onToggle: () => setState(() {
                          _expandedId = _expandedId == filtered[i].id
                              ? null
                              : filtered[i].id;
                        }),
                      ),
                    ),
                  ),
                ],
              );
            },
            orElse: () =>
                Center(child: CircularProgressIndicator(color: p.primary)),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AppTextField(
        hint: 'Cari meja atau nama pelanggan...',
        leadingIcon: Icons.search,
        controller: controller,
        onChanged: onChanged,
        subtle: true,
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int total;
  final int count;
  const _SummaryChip({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: p.warningContainer,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: p.warning.withValues(alpha: 0.33)),
        ),
        child: Row(
          children: [
            const Icon(Icons.bookmark_added_outlined,
                color: Color(0xFF7C4A0E), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Total ${total.currencyFormatRp.trim()} di $count draft',
                style: AppTypography.bodyM.copyWith(
                  color: const Color(0xFF7C4A0E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDrafts extends StatelessWidget {
  const _EmptyDrafts();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppEmptyState(
      visual: _EmptyVisual(),
      title: 'Belum ada Open Bill',
      body:
          'Order yang disimpan sementara akan muncul di sini. Berguna saat pelanggan masih duduk dan akan bayar nanti.',
      helperCard: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CARA BIKIN OPEN BILL',
            style: AppTypography.labelM.copyWith(
              color: p.onSurfaceVar,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const AppNumberedStep(
            n: 1,
            text: 'Tambahkan menu di Home',
          ),
          const AppNumberedStep(
            n: 2,
            text: 'Buka keranjang, tekan Simpan Open Bill',
          ),
          const AppNumberedStep(
            n: 3,
            text: 'Open Bill muncul di halaman ini',
          ),
        ],
      ),
      primaryAction: AppButton(
        label: 'Buat order baru',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class _EmptyVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: 140,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 78,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.smAll,
                border: Border.all(color: p.outlineSoft),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      height: 6,
                      width: i.isEven ? 50 : 38,
                      decoration: BoxDecoration(
                        color: p.outlineSoft,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: p.primaryContainer.withValues(alpha: 0.66),
                borderRadius: AppRadius.smAll,
                border: Border.all(
                  color: p.primary.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(Icons.add, color: p.primary, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
