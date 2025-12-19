import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/session.dart';
import 'package:shopping_list_app/widgets/common/logo.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_list_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final store = Provider.of<AppStore>(context, listen: false);

    try {
      final User? user = await _authService.signIn(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      if (user != null && mounted) {
        await store.login(Session(userId: user.uid, lastLoginAt: DateTime.now()));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Вітаємо! Ви успішно увійшли в систему'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      } else {
        setState(() => _error = 'Неправильний email або пароль');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        setState(() => _error = 'Неправильний email або пароль');
      } else {
        setState(() => _error = 'Сталася помилка: ${e.message}');
      }
    }
  }

  void _fillDemo() {
    setState(() {
      _emailController.text = 'demo@example.com';
      _passwordController.text = 'demo1234';
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _error = null);

    final store = Provider.of<AppStore>(context, listen: false);

    try {
      final User? user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        // Check if this is a new user (just signed in with Google for the first time)
        // We'll check if they have email/password provider
        final hasEmailPassword = user.providerData
            .any((provider) => provider.providerId == 'password');

        // If user doesn't have email/password provider, show password dialog
        if (!hasEmailPassword) {
          final passwordSet = await _showPasswordDialog();
          if (passwordSet == false && mounted) {
            // User canceled or failed to set password
            // Still allow them to proceed, but they won't be able to use email/password login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Пароль не встановлено. Ви зможете встановити його пізніше в налаштуваннях.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        if (mounted) {
          await store.login(Session(userId: user.uid, lastLoginAt: DateTime.now()));

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вітаємо! Ви успішно увійшли в систему'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Помилка входу через Google: ${e.toString()}');
      }
    }
  }

  Future<bool?> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    bool isLoading = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              title: Text(
                'Створіть пароль для вашого акаунту',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Встановіть пароль, щоб мати можливість входити через email/пароль у майбутньому.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF374151)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введіть пароль';
                          }
                          if (value.length < 8) {
                            return 'Пароль має бути мінімум 8 символів';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Підтвердження паролю',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF374151)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirmPassword = !obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Підтвердіть пароль';
                          }
                          if (value != passwordController.text) {
                            return 'Паролі не співпадають';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: Text(
                    'Пропустити',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() => isLoading = true);

                            final success = await _authService.setPassword(
                              passwordController.text,
                            );

                            if (dialogContext.mounted) {
                              if (success) {
                                Navigator.of(dialogContext).pop(true);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Пароль успішно встановлено'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                setDialogState(() => isLoading = false);
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Помилка встановлення паролю. Спробуйте пізніше.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Зберегти'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Logo.large(),
                const SizedBox(height: 16),
                Text(
                  'Менеджер покупок',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Керуйте своїми списками покупок',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Вхід',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.red[900]!.withValues(alpha: 0.2)
                                  : Colors.red[50],
                              border: Border.all(
                                color: isDark
                                    ? Colors.red[800]!
                                    : Colors.red[200]!,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.red[400]
                                    : Colors.red[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: AppSizes.iconSizeSmall,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: AppSizes.paddingXS),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: AppSizes.inputFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.paddingSM),
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                color: AppColorScheme.getTextPrimary(context),
                                fontSize: AppSizes.inputFontSize,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'your@email.com',
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF374151)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.inputBorderRadius,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColorScheme.getBorderMedium(
                                      context,
                                    ),
                                    width: AppSizes.borderWidthThin,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.inputBorderRadius,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColorScheme.getBorderMedium(
                                      context,
                                    ),
                                    width: AppSizes.borderWidthThin,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.inputBorderRadius,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.borderWidthMedium,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMD,
                                  vertical: AppSizes.paddingMD,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введіть email';
                                }
                                if (!value.contains('@')) {
                                  return 'Неправильний формат email';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacingLG),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: AppSizes.iconSizeSmall,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: AppSizes.paddingXS),
                                Text(
                                  'Пароль',
                                  style: TextStyle(
                                    fontSize: AppSizes.inputFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.paddingSM),
                            TextFormField(
                              controller: _passwordController,
                              style: TextStyle(
                                color: AppColorScheme.getTextPrimary(context),
                                fontSize: AppSizes.inputFontSize,
                              ),
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Ваш пароль',
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF374151)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.inputBorderRadius,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColorScheme.getBorderMedium(
                                      context,
                                    ),
                                    width: AppSizes.borderWidthThin,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.inputBorderRadius,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColorScheme.getBorderMedium(
                                      context,
                                    ),
                                    width: AppSizes.borderWidthThin,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.inputBorderRadius,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.borderWidthMedium,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMD,
                                  vertical: AppSizes.paddingMD,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  iconSize: AppSizes.iconSizeSmall,
                                  color: AppColorScheme.getTextTertiary(
                                    context,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введіть пароль';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: AppSizes.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: AppSizes.buttonPadding,
                              minimumSize: const Size(0, AppSizes.buttonHeight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.buttonBorderRadius,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Увійти',
                              style: TextStyle(
                                fontSize: AppSizes.buttonFontSize,
                                fontWeight: AppSizes.buttonFontWeight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.grey[700] : Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'АБО',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.grey[700] : Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: AppSizes.buttonHeight,
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF374151)
                                  : Colors.white,
                              foregroundColor: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                              padding: AppSizes.buttonPadding,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.buttonBorderRadius,
                                ),
                              ),
                            ),
                            icon: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    color: Color(0xFF4285F4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            label: const Text(
                              'Увійти через Google',
                              style: TextStyle(
                                fontSize: AppSizes.buttonFontSize,
                                fontWeight: AppSizes.buttonFontWeight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: 'Немає акаунту? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.go('/register'),
                                    child: Text(
                                      'Зареєструватися',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: const Color(0xFF2563EB),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: _fillDemo,
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Demo: demo@example.com / demo1234',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
