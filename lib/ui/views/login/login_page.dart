import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_config.dart';
import 'reset_password_page.dart';

enum _AuthMode { signIn, signUp }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _busy = false;
  _AuthMode _mode = _AuthMode.signIn;

  @override
  void initState() {
    super.initState();
    final params = Uri.base.queryParameters;
    if (params.containsKey('error')) {
      final message = params['error_description'] ?? params['error']!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败：$message')),
        );
      });
    }

    if (_isRecoveryFlow()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context)
            .pushReplacementNamed(ResetPasswordPage.routeName);
      });
    }
  }

  bool _isRecoveryFlow() {
    final uri = Uri.base;
    if (uri.queryParameters['type'] == 'recovery') return true;
    if (uri.fragment.contains('type=recovery')) return true;
    return false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (_busy) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('请输入邮箱和密码');
      return;
    }
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('登录失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleEmailSignUp() async {
    if (_busy) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage('请完整填写注册信息');
      return;
    }
    if (password != confirm) {
      _showMessage('两次密码不一致');
      return;
    }

    setState(() => _busy = true);
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      if (res.session == null) {
        _showMessage('注册成功，请使用邮箱登录');
      }
      setState(() => _mode = _AuthMode.signIn);
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('注册失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = await _promptForEmail(context);
    if (email == null || email.isEmpty) return;
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: _redirectUri(),
      );
      _showMessage('已发送邮件，请查收');
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('发送失败，请重试');
    }
  }

  String _redirectUri() {
    final uri = Uri.base;
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}/';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _t(bool isChina, String cn, String en) => isChina ? cn : en;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = AppConfigScope.of(context);
    final isChina = config.isChina;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      config.displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t(isChina, '智能课时记录与提醒助手', 'Smart class tracking & reminders'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SegmentedButton<_AuthMode>(
                segments: [
                  ButtonSegment(
                    value: _AuthMode.signIn,
                    label: Text(_t(isChina, '登录', 'Sign in')),
                  ),
                  ButtonSegment(
                    value: _AuthMode.signUp,
                    label: Text(_t(isChina, '注册', 'Sign up')),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (value) {
                  setState(() => _mode = value.first);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _t(isChina, '邮箱', 'Email'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _t(isChina, '密码', 'Password'),
                ),
              ),
              if (_mode == _AuthMode.signUp) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _t(isChina, '确认密码', 'Confirm password'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy
                    ? null
                    : (_mode == _AuthMode.signIn
                        ? _handleEmailSignIn
                        : _handleEmailSignUp),
                child: Text(
                  _busy
                      ? _t(isChina, '处理中...', 'Processing...')
                      : (_mode == _AuthMode.signIn
                          ? _t(isChina, '登录', 'Sign in')
                          : _t(isChina, '注册', 'Sign up')),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleResetPassword,
                  child: Text(_t(isChina, '忘记密码', 'Forgot password')),
                ),
              ),
              const SizedBox(height: 12),
              if (!isChina) ...[
                FilledButton.icon(
                  onPressed: _busy ? null : () => _handleOAuth(OAuthProvider.google),
                  icon: const _LogoIcon.asset('assets/icons/google.png'),
                  label: Text(_t(isChina, '使用 Google 登录', 'Continue with Google')),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : () => _handleOAuth(OAuthProvider.apple),
                  icon: const Icon(Icons.apple),
                  label: Text(_t(isChina, '使用 Apple 登录', 'Continue with Apple')),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (isChina)
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const _LogoIcon.asset('assets/icons/wechat.png'),
                  label: Text(_t(isChina, '使用微信登录', 'WeChat')),
                ),
              const SizedBox(height: 16),
              Text(
                _t(isChina, '登录即代表同意《服务条款》和《隐私政策》', 'By signing in, you agree to the Terms and Privacy Policy'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOAuth(OAuthProvider provider) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: _redirectUri(),
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('登录失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon.asset(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

Future<String?> _promptForEmail(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('重置密码'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: '请输入邮箱'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('发送邮件'),
          ),
        ],
      );
    },
  );
}
