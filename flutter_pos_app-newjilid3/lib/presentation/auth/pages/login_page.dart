import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/constants/store_branding.dart';
import '../../../core/components/feedback.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../bloc/login/login_bloc.dart';
import 'splash_page.dart';

/// Reskinned Login page — matches `LoginA` in
/// `.claude/new-design/screens/login.jsx`.
///
/// Layout: surface bg → BrandMark + tagline → product name + subtitle →
/// email/password fields with focus halo → "Lupa password?" → primary button
/// → version footer.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _emailError = _emailCtrl.text.trim().isEmpty ? 'Email wajib diisi' : null;
      _passwordError =
          _passwordCtrl.text.isEmpty ? 'Password wajib diisi' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(
          LoginEvent.login(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xxxl),
                      _BrandHeader(),
                      const SizedBox(height: 28),
                      _TitleBlock(),
                      const SizedBox(height: 36),
                      _buildForm(p),
                      const SizedBox(height: 28),
                      _buildSubmit(),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'v1.0.0 · build 1',
                        textAlign: TextAlign.center,
                        style:
                            AppTypography.bodyS.copyWith(color: p.onSurfaceVar),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(AppPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Email',
          hint: StoreBranding.kasirEmail,
          leadingIcon: Icons.mail_outline,
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: 'Password',
          hint: 'Password',
          leadingIcon: Icons.lock_outline,
          controller: _passwordCtrl,
          obscure: !_passwordVisible,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          trailing: InkWell(
            onTap: () => setState(() => _passwordVisible = !_passwordVisible),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                _passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: p.onSurfaceVar,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => AppSnackbar.info(
              context,
              'Hubungi admin untuk reset password',
            ),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Lupa password?',
                style: AppTypography.labelL.copyWith(color: p.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmit() {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          success: (auth) async {
            await AuthLocalDatasource().saveAuthData(auth);
            if (!context.mounted) return;
            // SplashPage owns post-auth routing: it queries the BE for the
            // open shift and pushes either BukaKasirPage or DashboardPage.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashPage()),
              (route) => false,
            );
          },
          error: (message) => AppSnackbar.error(context, message),
        );
      },
      builder: (context, state) {
        final loading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return AppButton(
          label: 'Login',
          loading: loading,
          onPressed: loading ? null : _submit,
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        BrandMark(size: 76),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(
          StoreBranding.name,
          textAlign: TextAlign.center,
          style:
              AppTypography.displayM.copyWith(color: p.onSurface, fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          StoreBranding.tagline,
          textAlign: TextAlign.center,
          style: AppTypography.bodyS.copyWith(
            color: p.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk ke akun kasir / admin',
          style: AppTypography.bodyM.copyWith(color: p.onSurfaceVar),
        ),
      ],
    );
  }
}
