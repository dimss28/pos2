import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/components/app_app_bar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_card.dart';
import '../../../../core/components/app_chip.dart';
import '../../../../core/components/app_empty_state.dart';
import '../../../../core/components/app_icon_button.dart';
import '../../../../core/components/app_section_label.dart';
import '../../../../core/components/feedback.dart';
import '../../../../core/components/product_img.dart';
import '../../../../core/extensions/int_ext.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/response/product_sales_report.dart';
import '../../../../data/models/response/summary_response_model.dart';
import '../../bloc/report/product_sales/product_sales_bloc.dart';
import '../../bloc/report/summary/summary_bloc.dart';
import 'utils/helper_pdf_service.dart';
import 'utils/invoice.dart';

enum _ReportRange { today, week, month, custom }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  static final _df = DateFormat('yyyy-MM-dd');
  static final _human = DateFormat('d MMM yyyy', 'id');
  _ReportRange _range = _ReportRange.today;
  late DateTime _from;
  late DateTime _to;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _applyRange(_ReportRange.today);
  }

  void _applyRange(_ReportRange r, {DateTime? from, DateTime? to}) {
    final now = DateTime.now();
    DateTime newFrom;
    DateTime newTo = DateTime(now.year, now.month, now.day);
    switch (r) {
      case _ReportRange.today:
        newFrom = newTo;
      case _ReportRange.week:
        final mondayOffset = now.weekday - 1;
        newFrom = newTo.subtract(Duration(days: mondayOffset));
      case _ReportRange.month:
        newFrom = DateTime(now.year, now.month, 1);
      case _ReportRange.custom:
        newFrom = from ?? newTo;
        newTo = to ?? newTo;
    }
    setState(() {
      _range = r;
      _from = newFrom;
      _to = newTo;
    });
    _fetch();
  }

  void _fetch() {
    final from = _df.format(_from);
    final to = _df.format(_to);
    context.read<SummaryBloc>().add(SummaryEvent.getSummary(from, to));
    context
        .read<ProductSalesBloc>()
        .add(ProductSalesEvent.getProductSales(from, to));
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    _applyRange(_ReportRange.custom, from: picked.start, to: picked.end);
  }

  Future<void> _exportPdf({
    required Summary summary,
    required List<ProductSales> productSales,
  }) async {
    if (productSales.isEmpty) {
      AppSnackbar.info(context, 'Tidak ada data untuk di-export');
      return;
    }
    setState(() => _exporting = true);
    try {
      final pdfFile = await Invoice.generate(productSales, summary);
      dev.log('pdf: $pdfFile', name: 'ReportPage');
      await HelperPdfService.openFile(pdfFile);
      if (!mounted) return;
      AppSnackbar.success(context, 'PDF berhasil dibuat');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Gagal export: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _rangeLabel() {
    if (_from.year == _to.year &&
        _from.month == _to.month &&
        _from.day == _to.day) {
      return _human.format(_from);
    }
    return '${_human.format(_from)} – ${_human.format(_to)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: 'Laporan',
        subtitle: _rangeLabel(),
        trailing: [
          BlocBuilder<SummaryBloc, SummaryState>(
            builder: (context, sumState) {
              return BlocBuilder<ProductSalesBloc, ProductSalesState>(
                builder: (context, psState) {
                  final summary = sumState.maybeWhen(
                    success: (data) => data.data,
                    orElse: () => null,
                  );
                  final productSales = psState.maybeWhen(
                    success: (data) => data.data,
                    orElse: () => const <ProductSales>[],
                  );
                  return AppButton(
                    label: _exporting ? 'Membuat...' : 'PDF',
                    leadingIcon: Icons.picture_as_pdf_outlined,
                    size: AppButtonSize.sm,
                    fullWidth: false,
                    loading: _exporting,
                    onPressed: (summary == null || _exporting)
                        ? null
                        : () => _exportPdf(
                              summary: summary,
                              productSales: productSales,
                            ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _RangeChips(
            active: _range,
            onPick: (r) => r == _ReportRange.custom
                ? _pickCustomRange()
                : _applyRange(r),
          ),
          const AppSectionLabel('Ringkasan'),
          _SummaryGrid(),
          const AppSectionLabel('Penjualan per Produk'),
          _ProductSalesTable(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Data update real-time · Cetak struk & bukti via Riwayat',
              textAlign: TextAlign.center,
              style: AppTypography.bodyS.copyWith(
                color: p.onSurfaceVar,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChips extends StatelessWidget {
  final _ReportRange active;
  final ValueChanged<_ReportRange> onPick;
  const _RangeChips({required this.active, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final entry in const [
            (_ReportRange.today, 'Hari Ini'),
            (_ReportRange.week, 'Minggu Ini'),
            (_ReportRange.month, 'Bulan Ini'),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppChip(
                label: entry.$2,
                active: active == entry.$1,
                onTap: () => onPick(entry.$1),
              ),
            ),
          AppChip(
            label: 'Pilih tanggal',
            leadingIcon: Icons.calendar_today_outlined,
            active: active == _ReportRange.custom,
            onTap: () => onPick(_ReportRange.custom),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  static String _shortRp(int n) {
    if (n >= 1000000) {
      final juta = n / 1000000;
      return 'Rp${juta.toStringAsFixed(juta >= 10 ? 0 : 2)}jt';
    }
    if (n >= 1000) return 'Rp${n ~/ 1000}rb';
    return 'Rp$n';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const _GridSkeleton(),
          error: (msg) => AppCard(child: Text(msg)),
          success: (data) {
            final s = data.data;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Pendapatan',
                        value: _shortRp(s.totalRevenue),
                        accent: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        label: 'Item Terjual',
                        value: '${s.totalSoldQuantity}',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          orElse: () => const _GridSkeleton(),
        );
      },
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        for (var i = 0; i < 2; i++) ...[
          Expanded(
            child: Container(
              height: 92,
              decoration: BoxDecoration(
                color: p.surfaceVariant,
                borderRadius: AppRadius.mdAll,
              ),
            ),
          ),
          if (i == 0) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _MetricCard({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = accent ? p.primary : Colors.white;
    final labelFg = accent
        ? p.onPrimary.withValues(alpha: 0.85)
        : p.onSurfaceVar;
    final valueFg = accent ? p.onPrimary : p.onSurface;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
        border: accent ? null : Border.all(color: p.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelM.copyWith(
              color: labelFg,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.displayM.copyWith(
              color: valueFg,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProductSalesTable extends StatelessWidget {
  int _hueFor(int id) => (id * 47) % 360;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return BlocBuilder<ProductSalesBloc, ProductSalesState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: p.primary),
            ),
          ),
          error: (msg) => AppEmptyState.error(message: msg),
          success: (response) {
            final sales = response.data;
            if (sales.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: p.outlineSoft),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart,
                          color: p.onSurfaceVar, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada penjualan di rentang ini',
                        style: AppTypography.bodyM
                            .copyWith(color: p.onSurfaceVar),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: p.outlineSoft),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: p.surfaceVariant,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'PRODUK',
                            style: AppTypography.labelM.copyWith(
                              color: p.onSurfaceVar,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(
                            'QTY',
                            textAlign: TextAlign.right,
                            style: AppTypography.labelM.copyWith(
                              color: p.onSurfaceVar,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'TOTAL',
                            textAlign: TextAlign.right,
                            style: AppTypography.labelM.copyWith(
                              color: p.onSurfaceVar,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < sales.length; i++) ...[
                    _ProductSalesRow(sale: sales[i], hue: _hueFor(sales[i].productId)),
                    if (i < sales.length - 1)
                      Container(height: 1, color: p.outlineSoft),
                  ],
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _ProductSalesRow extends StatelessWidget {
  final ProductSales sale;
  final int hue;
  const _ProductSalesRow({required this.sale, required this.hue});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final totalInt = int.tryParse(sale.totalPrice) ?? 0;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ProductImg(name: sale.productName, hue: hue, size: 36),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sale.productName,
                  style: AppTypography.bodyM.copyWith(
                    color: p.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${sale.productPrice.currencyFormatRp.trim()}',
                  style: AppTypography.bodyS.copyWith(
                    color: p.onSurfaceVar,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              sale.totalQuantity,
              textAlign: TextAlign.right,
              style: AppTypography.bodyM.copyWith(
                color: p.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              totalInt.currencyFormatRp.trim(),
              textAlign: TextAlign.right,
              style: AppTypography.bodyM.copyWith(
                color: p.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Imports retained for future use (action sheet overflow, icons row).
// ignore: unused_element
typedef _SuppressUnused = AppIconButton;
