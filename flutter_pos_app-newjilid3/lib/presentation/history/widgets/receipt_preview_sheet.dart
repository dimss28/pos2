import 'package:flutter/material.dart';

import '../../../core/components/app_button.dart';
import '../../../core/theme/app_palette.dart';
import '../../order/models/order_model.dart';
import 'history_receipt_helper.dart';

class ReceiptPreviewSheet extends StatelessWidget {
  final OrderModel order;

  const ReceiptPreviewSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lihat struk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: p.onSurface,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: ReceiptPreviewBody(order: order),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
              child: AppButton(
                label: 'Cetak struk',
                leadingIcon: Icons.print_outlined,
                onPressed: () async {
                  await printHistoryReceipt(context, order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
