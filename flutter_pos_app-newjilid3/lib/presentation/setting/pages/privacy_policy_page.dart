import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/components/app_app_bar.dart';
import '../../../core/components/app_button.dart';
import '../../../core/components/app_empty_state.dart';
import '../../../core/constants/variables.dart';
import '../../../core/theme/app_palette.dart';

/// In-app WebView for the BE-hosted privacy policy (`/api/privacy`).
/// Replaces the previous external-browser launch so the user never leaves
/// the app — required by Play Store reviewers who expect the policy link
/// to be reachable from inside the app without bouncing out.
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // ignore: avoid_print
            print('[PrivacyWebView] start: $url');
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (url) {
            // ignore: avoid_print
            print('[PrivacyWebView] finish: $url');
            setState(() => _loading = false);
          },
          onWebResourceError: (e) {
            // ignore: avoid_print
            print(
              '[PrivacyWebView] error: code=${e.errorCode} '
              'type=${e.errorType} mainFrame=${e.isForMainFrame} '
              'desc=${e.description}',
            );
            // Surface anything that looks like a page-level failure.
            if (e.isForMainFrame ?? true) {
              setState(() {
                _loading = false;
                _error = e.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('${Variables.baseUrl}/api/privacy'));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: const AppAppBar(
        title: 'Kebijakan Privasi',
        subtitle: 'Cara kami memperlakukan data Anda',
      ),
      body: _error != null
          ? AppEmptyState.error(
              message: _error!,
              onRetry: () => _controller
                  .loadRequest(Uri.parse('${Variables.baseUrl}/api/privacy')),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: p.surfaceVariant,
                      color: p.primary,
                      minHeight: 2,
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppButton(
            label: 'Tutup',
            variant: AppButtonVariant.outline,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }
}
