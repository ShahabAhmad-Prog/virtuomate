import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/config/demo_account_config.dart';
import 'package:virtuomate_flutter/ui/app_text.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/routes.dart';
import 'package:virtuomate_flutter/ui/shared/form_validators.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/virtuomate_runtime.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

bool _googleOAuthConfigured() => AppConfig.googleWebClientId != null;

bool _googleSignInReady(BuildContext context) {
  if (!AppConfig.useFirebase) return false;
  try {
    return VirtuoMateScope.of(context).firebaseAuthReady;
  } catch (_) {
    final runtime = VirtuoMateRuntime.maybeOf(context);
    return runtime?.firebaseEnabled ?? false;
  }
}

String _googleSignInNotReadyMessage(BuildContext context) {
  final runtime = VirtuoMateRuntime.maybeOf(context);
  final warn = runtime?.bootstrapWarning;
  if (warn != null && warn.isNotEmpty) {
    return 'Firebase did not start:\n$warn\n\n'
        'Try: full restart (not hot reload), emulator with Google Play, '
        'and google-services.json in android/app/.';
  }
  return 'Google Sign-In needs Firebase. Stop the app completely, then run:\n'
      '.\\scripts\\run_dev.ps1\n'
      'or: flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true';
}

Widget _googleSignInButton({
  required bool loading,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: VirtuoMvpColors.text,
        side: const BorderSide(color: VirtuoMvpColors.stroke2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: VirtuoMvpColors.inputFill,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontWeight: FontWeight.w900,
                fontSize: 15,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Continue with Google',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.firebaseEnabled,
    this.useBackendApi = false,
    super.key,
  });

  final bool firebaseEnabled;
  final bool useBackendApi;

  @override
  Widget build(BuildContext context) {
    void goLogin() => Navigator.pushNamed(context, AppRoutes.login);

    return MvpShell(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            VirtuoMvpSpacing.lg,
            48,
            VirtuoMvpSpacing.lg,
            24,
          ),
          child: Column(
            children: [
              const MvpWelcomeLogo(),
              const SizedBox(height: 20),
              const Text(
                'NEURAL COACHING SYSTEM v3.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: VirtuoMvpColors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Advanced AI-Powered Intelligence for Professional Evolution',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: VirtuoMvpColors.textMuted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              VCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    VButton(
                      title: 'Neural Network Coaching',
                      variant: VButtonVariant.ghost,
                      icon: Icons.hub_outlined,
                      expanded: true,
                      onPressed: goLogin,
                    ),
                    const SizedBox(height: 10),
                    VButton(
                      title: 'Adaptive AI Learning',
                      variant: VButtonVariant.ghost,
                      icon: Icons.auto_awesome_outlined,
                      expanded: true,
                      onPressed: goLogin,
                    ),
                    const SizedBox(height: 10),
                    VButton(
                      title: 'Real-time Performance Analysis',
                      variant: VButtonVariant.ghost,
                      icon: Icons.flash_on_outlined,
                      expanded: true,
                      onPressed: goLogin,
                    ),
                    const SizedBox(height: 16),
                    VButton(
                      title: 'Initialize System',
                      icon: Icons.flash_on,
                      expanded: true,
                      onPressed: goLogin,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      firebaseEnabled
                          ? (useBackendApi
                              ? 'CLOUD READY • Firebase + API connected'
                              : 'FIREBASE READY • Sign in to start')
                          : 'LOCAL DEMO MODE • Use email login below',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: VirtuoMvpColors.textFaint,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                child: Text(
                  AppText.tr(context, 'register'),
                  style: const TextStyle(
                    color: VirtuoMvpColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                firebaseEnabled
                    ? (useBackendApi ? 'Production: Firebase + API' : 'Firebase: connected')
                    : 'Development: mock mode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: firebaseEnabled ? VirtuoMvpColors.green : VirtuoMvpColors.amber,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _error = '';
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    final c = VirtuoMateScope.of(context);
    final ok = await c.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    if (!AppConfig.useBackendApi) {
      c.startRealtimeSync();
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (_) => false,
    );
  }

  Future<void> _forgotPassword() async {
    final emailErr = validateEmail(_email.text);
    if (emailErr != null) {
      setState(() => _error = emailErr);
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    final c = VirtuoMateScope.of(context);
    final ok = await c.sendPasswordResetEmail(_email.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset email sent. Check your inbox.'),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    if (!_googleSignInReady(context)) {
      setState(() => _error = _googleSignInNotReadyMessage(context));
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    final c = VirtuoMateScope.of(context);
    final ok = await c.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    if (!AppConfig.useBackendApi) {
      c.startRealtimeSync();
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  Future<void> _tryDemoLogin() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    final c = VirtuoMateScope.of(context);
    final ok = await c.loginDemo();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final showGoogle = _googleOAuthConfigured();
    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MvpTopBar(onBack: () => Navigator.maybePop(context)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                VirtuoMvpSpacing.lg,
                0,
                VirtuoMvpSpacing.lg,
                VirtuoMvpSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VirtuoMvpColors.surface2,
                          border: Border.all(color: VirtuoMvpColors.stroke),
                        ),
                        child: const Icon(Icons.flash_on, color: VirtuoMvpColors.text, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Access Neural Interface',
                              style: TextStyle(
                                color: VirtuoMvpColors.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Authenticate to access your AI coaching system',
                              style: TextStyle(
                                color: VirtuoMvpColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  VCard(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _mvpLabel('Email Address'),
                          VTextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _mvpLabel('Password'),
                              GestureDetector(
                                onTap: _loading ? null : _forgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: VirtuoMvpColors.cyan,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          VTextField(
                            controller: _password,
                            obscureText: true,
                            validator: validatePassword,
                          ),
                          if (_error.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 12)),
                          ],
                          const SizedBox(height: 14),
                          VButton(
                            title: _loading ? 'Authenticating…' : 'Access System',
                            icon: Icons.flash_on,
                            expanded: true,
                            onPressed: _loading ? null : _submit,
                          ),
                          if (showGoogle) ...[
                            const SizedBox(height: 14),
                            const Row(
                              children: [
                                Expanded(child: Divider(color: VirtuoMvpColors.stroke)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: VirtuoMvpColors.textFaint,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: VirtuoMvpColors.stroke)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _googleSignInButton(
                              loading: _loading,
                              onPressed: _loading ? null : _signInWithGoogle,
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Text(
                            'Quick access (demo account)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: VirtuoMvpColors.textFaint,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DemoAccountConfig.email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: VirtuoMvpColors.cyan.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          VButton(
                            title: 'Try demo login',
                            variant: VButtonVariant.outline,
                            icon: Icons.bolt_outlined,
                            expanded: true,
                            onPressed: _loading ? null : _tryDemoLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                          children: [
                            const TextSpan(text: 'Need access credentials? '),
                            TextSpan(
                              text: 'Register New Account',
                              style: TextStyle(
                                color: VirtuoMvpColors.cyan,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mvpLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          color: VirtuoMvpColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agree = true;
  String _error = '';
  bool _loading = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      setState(() => _error = 'Please accept the terms to continue.');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    final c = VirtuoMateScope.of(context);
    final ok = await c.register(
      _email.text.trim(),
      _password.text,
      displayName: _fullName.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    if (!AppConfig.useBackendApi) {
      c.startRealtimeSync();
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  Future<void> _signInWithGoogle() async {
    if (_loading) return;
    if (!_googleSignInReady(context)) {
      setState(() => _error = _googleSignInNotReadyMessage(context));
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    final c = VirtuoMateScope.of(context);
    final ok = await c.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    if (!AppConfig.useBackendApi) {
      c.startRealtimeSync();
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  Future<void> _tryDemoLogin() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    final c = VirtuoMateScope.of(context);
    final ok = await c.loginDemo();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final showGoogle = _googleOAuthConfigured();
    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MvpTopBar(onBack: () => Navigator.maybePop(context)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                VirtuoMvpSpacing.lg,
                0,
                VirtuoMvpSpacing.lg,
                VirtuoMvpSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Initialize User Profile',
                    style: TextStyle(
                      color: VirtuoMvpColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Register to begin your neural coaching journey',
                    style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  VCard(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _regLabel('Full Name'),
                          VTextField(
                            controller: _fullName,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => validateRequired(v, 'Full name'),
                          ),
                          const SizedBox(height: 14),
                          _regLabel('Email Address'),
                          VTextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                          ),
                          const SizedBox(height: 14),
                          _regLabel('Password'),
                          VTextField(
                            controller: _password,
                            obscureText: true,
                            validator: validatePassword,
                          ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => setState(() => _agree = !_agree),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: _agree ? VirtuoMvpColors.cyan : Colors.transparent,
                                  border: Border.all(color: VirtuoMvpColors.stroke2),
                                ),
                                child: _agree
                                    ? const Icon(Icons.check, size: 14, color: VirtuoMvpColors.primaryTextOnPurple)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: VirtuoMvpColors.textMuted,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: VirtuoMvpColors.cyan,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: VirtuoMvpColors.cyan,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 12)),
                        ],
                        const SizedBox(height: 14),
                        VButton(
                          title: _loading ? 'Creating account…' : 'Create Account',
                          icon: Icons.flash_on,
                          expanded: true,
                          onPressed: _loading ? null : _submit,
                        ),
                        if (showGoogle) ...[
                          const SizedBox(height: 14),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: VirtuoMvpColors.stroke)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: VirtuoMvpColors.textFaint,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: VirtuoMvpColors.stroke)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _googleSignInButton(
                            loading: _loading,
                            onPressed: _loading ? null : _signInWithGoogle,
                          ),
                        ],
                        if (kDebugMode) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Quick access (demo account)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: VirtuoMvpColors.textFaint, fontSize: 11),
                        ),
                        const SizedBox(height: 10),
                        VButton(
                          title: 'Try demo login',
                          variant: VButtonVariant.outline,
                          icon: Icons.bolt_outlined,
                          expanded: true,
                          onPressed: _loading ? null : _tryDemoLogin,
                        ),
                        ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: VirtuoMvpColors.cyan,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _regLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          color: VirtuoMvpColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
