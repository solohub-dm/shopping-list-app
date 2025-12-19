import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list_app/services/app_store.dart';
import 'package:shopping_list_app/models/session.dart';
import 'package:shopping_list_app/models/user.dart';
import 'package:shopping_list_app/widgets/common/logo.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shopping_list_app/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  final AuthService _authService = AuthService();

  UserSegment _determineSegment(String email) {
    const corporateDomains = ['lpnu.ua', 'softserve.inc', 'google.com'];
    final domain = email.split('@').last.toLowerCase();
    if (corporateDomains.contains(domain)) {
      return UserSegment.corporate;
    }
    return UserSegment.personal;
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final store = Provider.of<AppStore>(context, listen: false);

    try {
      final firebase_auth.User? user = await _authService.signUp(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      if (user != null && mounted) {
        // 1. Determine segment
        final segment = _determineSegment(_emailController.text.trim());

        // 2. Add to local store (This triggers the Analytics setUserProperty)
        await store.addUser(
          id: user.uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
          segment: segment,
        );

        // 3. Login
        await store.login(Session(userId: user.uid, lastLoginAt: DateTime.now()));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Вітаємо, ${_firstNameController.text.trim()}! Акаунт успішно створено',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Помилка реєстрації. Можливо, цей email вже використовується.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка: ${e.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final store = Provider.of<AppStore>(context, listen: false);

    try {
      final firebase_auth.User? user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        // Check if this is a new user (just signed in with Google for the first time)
        final hasEmailPassword = user.providerData.any(
          (provider) => provider.providerId == 'password',
        );

        // If user doesn't have email/password provider, show password dialog
        if (!hasEmailPassword) {
          final passwordSet = await _showPasswordDialog();
          if (passwordSet == false && mounted) {
            // User canceled or failed to set password
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
          // Check if user exists in local store
          final userExists = store.users.any((u) => u.id == user.uid);

          if (!userExists) {
            // Determine segment from email
            final email = user.email ?? '';
            final segment = _determineSegment(email);

            // Parse display name (format: "FirstName LastName" or just "Name")
            final displayName = user.displayName ?? '';
            final nameParts = displayName.split(' ');
            final firstName = nameParts.isNotEmpty ? nameParts.first : '';
            final lastName = nameParts.length > 1
                ? nameParts.sublist(1).join(' ')
                : '';

            // Add to local store
            await store.addUser(
              id: user.uid,
              firstName: firstName.isNotEmpty ? firstName : 'User',
              lastName: lastName,
              email: email,
              password: null,
              segment: segment,
            );
          }

          if (!mounted) return;

          await store.login(Session(userId: user.uid, lastLoginAt: DateTime.now()));

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вітаємо! Акаунт успішно створено'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка реєстрації через Google: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
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
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
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
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
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
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
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
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
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
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
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
                                      content: Text(
                                        'Пароль успішно встановлено',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                setDialogState(() => isLoading = false);
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                  'Створіть свій акаунт',
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
                          'Реєстрація',
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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ім\'я *',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _firstNameController,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "Ім'я обов'язкове";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Ваше ім'я",
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF374151)
                                          : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Colors.grey[600]!
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Colors.grey[600]!
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2563EB),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Прізвище *',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _lastNameController,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "Прізвище обов'язкове";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Ваше прізвище",
                                      filled: true,
                                      fillColor: isDark
                                          ? const Color(0xFF374151)
                                          : Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Colors.grey[600]!
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Colors.grey[600]!
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2563EB),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Email *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Email обов'язковий";
                                }
                                if (!RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(value)) {
                                  return "Неправильний формат email";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'your@email.com',
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF374151)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Пароль *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Пароль обов'язковий";
                                }
                                if (value.length < 8) {
                                  return "Пароль має бути мінімум 8 символів";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Введіть пароль',
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF374151)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  iconSize: 16,
                                  color: Colors.grey[400],
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Підтвердження паролю *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                              obscureText: _obscureConfirmPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Підтвердження паролю обов'язкове";
                                }
                                if (value != _passwordController.text) {
                                  return "Паролі не співпадають";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Повторіть пароль',
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF374151)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  iconSize: 16,
                                  color: Colors.grey[400],
                                  onPressed: () {
                                    setState(
                                      () => _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2563EB), // blue-600
                                Color(0xFF4F46E5), // indigo-600
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _handleSubmit,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Зареєструватися',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
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
                              'Зареєструватися через Google',
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
                              text: 'Вже маєте акаунт? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: Text(
                                      'Увійти',
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
