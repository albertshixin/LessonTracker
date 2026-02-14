import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/supabase_profile_repository.dart';
import '../login/login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  static const routeName = '/account';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('账号与安全')),
        body: _LoggedOutSection(onLoginTap: () {
          Navigator.of(context).pushNamed(LoginPage.routeName);
        }),
      );
    }

    final repo = SupabaseProfileRepository(userId: user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账号与安全'),
      ),
      body: StreamBuilder<UserProfile>(
        stream: repo.watch(),
        builder: (context, snapshot) {
          final profile = snapshot.data ??
              UserProfile(
                id: user.id,
                displayName: user.userMetadata?['full_name'] as String?,
                email: user.email,
                phone: user.phone,
                photoUrl: user.userMetadata?['avatar_url'] as String?,
                provider: user.appMetadata['provider'] as String?,
              );

          final displayName = profile.displayName ?? '未命名用户';
          final photoUrl = profile.photoUrl;
          final emailVerified = user.emailConfirmedAt != null;
          final linkedProviders = (user.identities ?? const [])
              .map((identity) => identity.provider)
              .toSet();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage:
                            photoUrl == null ? null : NetworkImage(photoUrl),
                        child: photoUrl == null
                            ? Text(
                                displayName.characters.take(1).toString(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '登录方式：${_providerLabel(profile.provider)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              emailVerified
                                  ? '邮箱已验证'
                                  : '邮箱未验证',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: emailVerified
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionTitle(title: '基本信息'),
              _BindTile(
                icon: Icons.person_outline,
                title: '昵称',
                value: profile.displayName,
                onTap: () async {
                  final value = await _promptForValue(
                    context,
                    title: '修改昵称',
                    hint: '请输入昵称',
                    initialValue: profile.displayName,
                  );
                  if (value != null && value.isNotEmpty) {
                    await repo.updateDisplayName(value);
                    if (!context.mounted) return;
                    _showSnackBar(context, '昵称已更新');
                  }
                },
              ),
              _BindTile(
                icon: Icons.phone_iphone,
                title: '手机号',
                value: profile.phone,
                onTap: () async {
                  final value = await _promptForValue(
                    context,
                    title: '绑定手机号',
                    hint: '请输入手机号',
                    keyboardType: TextInputType.phone,
                    initialValue: profile.phone,
                  );
                  if (value != null && value.isNotEmpty) {
                    await repo.updatePhone(value);
                    if (!context.mounted) return;
                    _showSnackBar(context, '手机号绑定成功');
                  }
                },
              ),
              _BindTile(
                icon: Icons.transgender,
                title: '性别',
                value: profile.gender,
                onTap: () async {
                  final value = await _promptForGender(context, profile.gender);
                  if (value != null && value.isNotEmpty) {
                    await repo.updateGender(value);
                    if (!context.mounted) return;
                    _showSnackBar(context, '性别已更新');
                  }
                },
              ),
              _BindTile(
                icon: Icons.cake_outlined,
                title: '出生日期',
                value: _formatDate(profile.birthDate),
                onTap: () async {
                  final value = await _pickDate(context, profile.birthDate);
                  if (value != null) {
                    await repo.updateBirthDate(value);
                    if (!context.mounted) return;
                    _showSnackBar(context, '出生日期已更新');
                  }
                },
              ),
              _BindTile(
                icon: Icons.public,
                title: '国家/地区',
                value: profile.country,
                onTap: () async {
                  final value = await _promptForValue(
                    context,
                    title: '修改国家/地区',
                    hint: '请输入国家或地区',
                    initialValue: profile.country,
                  );
                  if (value != null && value.isNotEmpty) {
                    await repo.updateCountry(value);
                    if (!context.mounted) return;
                    _showSnackBar(context, '国家/地区已更新');
                  }
                },
              ),
              const SizedBox(height: 12),
              _SectionTitle(title: '登录邮箱'),
              _BindTile(
                icon: Icons.mail_outline,
                title: '邮箱',
                value: user.email,
                onTap: () async {
                  final value = await _promptForValue(
                    context,
                    title: '修改登录邮箱',
                    hint: '请输入新邮箱',
                    initialValue: user.email,
                  );
                  if (value != null && value.isNotEmpty) {
                    try {
                      await Supabase.instance.client.auth.updateUser(
                        UserAttributes(email: value),
                      );
                      await repo.updateEmail(value);
                      if (!context.mounted) return;
                      _showSnackBar(context, '邮箱已更新，请查收验证邮件');
                    } on AuthException catch (e) {
                      if (!context.mounted) return;
                      _showSnackBar(context, e.message);
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              _SectionTitle(title: '绑定第三方账号'),
              _ProviderBindTile(
                title: 'Google',
                bound: linkedProviders.contains('google'),
                onBind: () => _linkIdentity(context, OAuthProvider.google),
              ),
              _ProviderBindTile(
                title: 'Apple',
                bound: linkedProviders.contains('apple'),
                onBind: () => _linkIdentity(context, OAuthProvider.apple),
              ),
              _ProviderBindTile(
                title: '微信',
                bound: linkedProviders.contains('wechat'),
                onBind: null,
                note: '需要自建微信 OAuth 接入',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  _showSnackBar(context, '已退出登录');
                  Navigator.of(context)
                      .pushReplacementNamed(LoginPage.routeName);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('退出登录'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoggedOutSection extends StatelessWidget {
  const _LoggedOutSection({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 72,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              '还未登录',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '登录后可同步课程、绑定邮箱和手机号',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onLoginTap,
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BindTile extends StatelessWidget {
  const _BindTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bound = value != null && value!.isNotEmpty;
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          bound ? value! : '未绑定',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: TextButton(
          onPressed: onTap,
          child: Text(bound ? '修改' : '绑定'),
        ),
      ),
    );
  }
}

class _ProviderBindTile extends StatelessWidget {
  const _ProviderBindTile({
    required this.title,
    required this.bound,
    required this.onBind,
    this.note,
  });

  final String title;
  final bool bound;
  final VoidCallback? onBind;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          bound ? '已绑定' : (note ?? '未绑定'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: TextButton(
          onPressed: bound ? null : onBind,
          child: Text(bound ? '已绑定' : '绑定'),
        ),
      ),
    );
  }
}

String _providerLabel(String? providerId) {
  switch (providerId) {
    case 'google':
      return 'Google';
    case 'apple':
      return 'Apple';
    case 'wechat':
      return '微信';
    default:
      return providerId ?? '未知';
  }
}

String? _formatDate(DateTime? date) {
  if (date == null) return null;
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Future<String?> _promptForValue(
  BuildContext context, {
  required String title,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  String? initialValue,
}) {
  final controller = TextEditingController(text: initialValue ?? '');
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          keyboardType: keyboardType,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('确认'),
          ),
        ],
      );
    },
  );
}

Future<String?> _promptForGender(BuildContext context, String? current) {
  final options = [
    '男',
    '女',
    '其他',
    '不公开',
  ];
  return showDialog<String>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text('选择性别'),
        children: options
            .map((value) => SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(value),
                  child: Row(
                    children: [
                      if (current == value)
                        const Icon(Icons.check, size: 16),
                      if (current == value) const SizedBox(width: 8),
                      Text(value),
                    ],
                  ),
                ))
            .toList(),
      );
    },
  );
}

Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? DateTime(now.year - 10, 1, 1),
    firstDate: DateTime(1900),
    lastDate: DateTime(now.year + 1),
  );
}

Future<void> _linkIdentity(BuildContext context, OAuthProvider provider) async {
  try {
    await Supabase.instance.client.auth.linkIdentity(
      provider,
      redirectTo: _redirectUri(),
    );
  } on AuthException catch (e) {
    _showSnackBar(context, e.message);
  } catch (_) {
    _showSnackBar(context, '绑定失败，请重试');
  }
}

String _redirectUri() {
  final uri = Uri.base;
  return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}/';
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
