import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_money_text_field.dart';
import '../../../core/components/app_section_label.dart';
import '../../../core/components/app_segmented_toggle.dart';
import '../../../core/components/app_sticky_footer.dart';
import '../../../core/components/app_switch_tile.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/components/feedback.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/response/promo_model.dart';
import '../bloc/promo/promo_bloc.dart';

class AddEditPromoPage extends StatefulWidget {
  final PromoModel? existing;
  const AddEditPromoPage({super.key, this.existing});

  @override
  State<AddEditPromoPage> createState() => _AddEditPromoPageState();
}

class _AddEditPromoPageState extends State<AddEditPromoPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late PromoType _type;
  late int _value;
  late int _minSubtotal;
  late bool _active;
  DateTime? _startsAt;
  DateTime? _endsAt;
  String? _nameError;

  bool get _isEdit => widget.existing?.id != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _type = e?.type ?? PromoType.percent;
    _value = e?.value ?? 0;
    _minSubtotal = e?.minSubtotal ?? 0;
    _active = e?.active ?? true;
    _startsAt = e?.startsAt;
    _endsAt = e?.endsAt;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool start) async {
    final initial =
        (start ? _startsAt : _endsAt) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _startsAt = picked;
      } else {
        _endsAt = picked;
      }
    });
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Nama promo wajib diisi');
      return;
    }
    final promo = PromoModel(
      id: widget.existing?.id,
      name: _nameCtrl.text.trim(),
      type: _type,
      value: _value,
      code: _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
      minSubtotal: _minSubtotal,
      startsAt: _startsAt,
      endsAt: _endsAt,
      active: _active,
    );
    context.read<PromoBloc>().add(PromoEvent.save(promo));
    AppSnackbar.success(context, _isEdit ? 'Promo diperbarui' : 'Promo dibuat');
    Navigator.of(context).maybePop();
  }

  Future<void> _confirmDelete() async {
    if (widget.existing?.id == null) return;
    final ok = await AppConfirm.show(
      context,
      title: 'Hapus promo?',
      body: 'Promo "${widget.existing!.name}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    context.read<PromoBloc>().add(PromoEvent.delete(widget.existing!.id!));
    AppSnackbar.info(context, 'Promo dihapus');
    Navigator.of(context).maybePop();
  }

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppAppBar(
        title: _isEdit ? 'Edit Promo' : 'Promo Baru',
        subtitle: 'Tentukan diskon untuk pelanggan',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          const AppSectionLabel('Informasi',
              margin: EdgeInsets.only(top: 4, bottom: 8)),
          AppTextField(
            label: 'Nama Promo',
            hint: 'cth. Happy Hour Coffee',
            controller: _nameCtrl,
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) {
                setState(() => _nameError = null);
              }
            },
          ),
          const SizedBox(height: 14),
          const AppSectionLabel('Tipe diskon'),
          AppSegmentedToggle<PromoType>(
            value: _type,
            onChanged: (v) => setState(() {
              _type = v;
              _value = 0;
            }),
            options: const [
              AppSegmentOption(value: PromoType.percent, label: 'Persen'),
              AppSegmentOption(value: PromoType.rupiah, label: 'Rupiah'),
              AppSegmentOption(value: PromoType.b1g1, label: 'B1G1'),
            ],
          ),
          const SizedBox(height: 14),
          if (_type == PromoType.percent)
            _PercentValueField(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            )
          else if (_type == PromoType.rupiah)
            AppMoneyTextField(
              label: 'Potongan Rupiah',
              initialValue: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
          const AppSectionLabel('Kode voucher (opsional)'),
          AppTextField(
            hint: 'cth. MEMBER10  (kosongkan = auto)',
            leadingIcon: Icons.confirmation_number_outlined,
            controller: _codeCtrl,
            subtle: true,
          ),
          const AppSectionLabel('Minimum belanja (opsional)'),
          AppMoneyTextField(
            initialValue: _minSubtotal,
            onChanged: (v) => setState(() => _minSubtotal = v),
          ),
          const AppSectionLabel('Jadwal'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today, color: p.primary),
                  title: const Text('Mulai'),
                  subtitle: Text(_fmtDate(_startsAt)),
                  trailing: _startsAt != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _startsAt = null),
                        )
                      : null,
                  onTap: () => _pickDate(true),
                ),
                Container(height: 1, color: p.outlineSoft),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.event, color: p.primary),
                  title: const Text('Selesai'),
                  subtitle: Text(_fmtDate(_endsAt)),
                  trailing: _endsAt != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _endsAt = null),
                        )
                      : null,
                  onTap: () => _pickDate(false),
                ),
              ],
            ),
          ),
          const AppSectionLabel('Status'),
          AppCard(
            padding: EdgeInsets.zero,
            child: AppSwitchTile(
              title: 'Aktifkan promo',
              subtitle:
                  _active ? 'Bisa dipakai sekarang' : 'Tersimpan tapi tidak aktif',
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
          ),
          if (_isEdit) ...[
            const SizedBox(height: 24),
            AppButton(
              label: 'Hapus promo',
              variant: AppButtonVariant.danger,
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      bottomNavigationBar: AppStickyFooter(
        child: AppButton(
          label: _isEdit ? 'Simpan perubahan' : 'Buat promo',
          onPressed: _submit,
        ),
      ),
    );
  }
}

class _PercentValueField extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _PercentValueField({required this.value, required this.onChanged});

  @override
  State<_PercentValueField> createState() => _PercentValueFieldState();
}

class _PercentValueFieldState extends State<_PercentValueField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.value > 0 ? widget.value.toString() : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppTextField(
      label: 'Persen Diskon',
      hint: '10',
      leadingIcon: Icons.percent,
      controller: _ctrl,
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final n = int.tryParse(v) ?? 0;
        widget.onChanged(n.clamp(0, 100));
      },
    );
  }
}
