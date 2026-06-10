import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_chip.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/components/app_icon_button.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../order/models/order_model.dart';
import '../bloc/history/history_bloc.dart';
import '../widgets/history_transaction_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? _expandedId;

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryEvent.fetch());
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    context.read<HistoryBloc>().add(
          HistoryEvent.filterByRange(
            range: HistoryDateRange.custom,
            from: picked.start,
            to: picked.end,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Riwayat Transaksi',
        subtitle: 'Transaksi yang sudah selesai',
        automaticallyImplyLeading: false,
        trailing: [
          AppIconButton(
            icon: Icons.calendar_today_outlined,
            variant: AppIconButtonVariant.surfaceVariant,
            tooltip: 'Pilih tanggal',
            onPressed: _pickCustomRange,
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () =>
                Center(child: CircularProgressIndicator(color: p.primary)),
            error: (msg) => Center(
              child: AppEmptyState.error(
                message: msg,
                onRetry: () => context
                    .read<HistoryBloc>()
                    .add(const HistoryEvent.fetch()),
              ),
            ),
            success: (all, filtered, range, _, __) {
              return Column(
                children: [
                  _FilterChipsRow(active: range),
                  _SummaryCard(filtered: filtered, range: range),
                  Expanded(
                    child: RefreshIndicator(
                      color: p.primary,
                      onRefresh: () async {
                        final bloc = context.read<HistoryBloc>();
                        bloc.add(const HistoryEvent.refresh());
                        await bloc.stream.firstWhere(
                          (s) => s.maybeWhen(
                            success: (_, __, ___, ____, _____) => true,
                            error: (_) => true,
                            orElse: () => false,
                          ),
                          orElse: () => bloc.state,
                        );
                      },
                      child: filtered.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 32),
                                _EmptyHistory(),
                              ],
                            )
                          : _OrderList(
                              orders: filtered,
                              expandedId: _expandedId,
                              onToggle: (id) => setState(() {
                                _expandedId = _expandedId == id ? null : id;
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

class _FilterChipsRow extends StatelessWidget {
  final HistoryDateRange active;
  const _FilterChipsRow({required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final entry in const [
              (HistoryDateRange.today, 'Hari Ini'),
              (HistoryDateRange.week, 'Minggu Ini'),
              (HistoryDateRange.month, 'Bulan Ini'),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppChip(
                  label: entry.$2,
                  active: active == entry.$1,
                  onTap: () => context
                      .read<HistoryBloc>()
                      .add(HistoryEvent.filterByRange(range: entry.$1)),
                ),
              ),
            AppChip(
              label: 'Pilih tanggal',
              leadingIcon: Icons.calendar_today_outlined,
              active: active == HistoryDateRange.custom,
              onTap: () {
                // Open the picker through the page; chip just signals state.
                final state = context.findAncestorStateOfType<_HistoryPageState>();
                state?._pickCustomRange();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<OrderModel> filtered;
  final HistoryDateRange range;
  const _SummaryCard({required this.filtered, required this.range});

  String get _label => switch (range) {
        HistoryDateRange.today => 'Pendapatan hari ini',
        HistoryDateRange.week => 'Pendapatan minggu ini',
        HistoryDateRange.month => 'Pendapatan bulan ini',
        HistoryDateRange.custom => 'Pendapatan rentang ini',
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = HistoryBloc.sumRevenue(filtered);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.onSurface,
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label.toUpperCase(),
                    style: AppTypography.labelM.copyWith(
                      color: p.surface.withValues(alpha: 0.66),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total.currencyFormatRp.trim(),
                    style: AppTypography.displayM.copyWith(
                      color: p.surface,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${filtered.length} transaksi',
                  style: AppTypography.bodyS.copyWith(
                    color: p.surface.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final int? expandedId;
  final ValueChanged<int?> onToggle;

  const _OrderList({
    required this.orders,
    required this.expandedId,
    required this.onToggle,
  });

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  String _labelFor(DateTime day) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    if (day.year == today.year &&
        day.month == today.month &&
        day.day == today.day) {
      return 'Hari Ini · ${_days[day.weekday - 1]}, ${day.day} ${_months[day.month - 1]}';
    }
    if (day.year == yesterday.year &&
        day.month == yesterday.month &&
        day.day == yesterday.day) {
      return 'Kemarin · ${day.day} ${_months[day.month - 1]}';
    }
    return '${_days[day.weekday - 1]}, ${day.day} ${_months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final groups = HistoryBloc.groupByDay(orders);
    final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, i) {
        final day = sortedKeys[i];
        final items = groups[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8, left: 2),
              child: Text(
                _labelFor(day).toUpperCase(),
                style: AppTypography.labelM.copyWith(
                  color: p.onSurfaceVar,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            for (var j = 0; j < items.length; j++) ...[
              HistoryTransactionCard(
                data: items[j],
                expanded: items[j].id != null &&
                    expandedId == items[j].id,
                onToggle: () => onToggle(items[j].id),
              ),
              if (j < items.length - 1) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      visual: _EmptyVisual(),
      title: 'Belum ada transaksi',
      body:
          'Setelah pelanggan bayar, riwayat akan muncul di sini lengkap dengan jumlah, metode bayar, dan jam transaksi.',
      primaryAction: AppButton(
        label: 'Mulai order baru',
        leadingIcon: Icons.add_shopping_cart,
        fullWidth: false,
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
      width: 200,
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final heights = [40.0, 60.0, 50.0, 80.0, 55.0];
          final isFilled = i == 3;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 22,
              height: heights[i],
              decoration: BoxDecoration(
                color: isFilled ? p.primary : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                border: isFilled
                    ? null
                    : Border.all(color: p.outline, width: 1.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}
