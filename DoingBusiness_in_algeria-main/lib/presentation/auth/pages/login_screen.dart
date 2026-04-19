import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/core/configs/theme/app_spacing.dart';
import 'package:doingbusiness/presentation/Profile/pages/forgot_password_screen.dart';
import 'package:doingbusiness/presentation/auth/controllers/signin_controller.dart';
import 'package:doingbusiness/presentation/auth/pages/signup_screen.dart';
import 'package:doingbusiness/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  LoginScreen — REDESIGNED
/// ════════════════════════════════════════════════════════════════════════
///  Changes from old screen:
///    UX:
///      ✔ Removed the heavy 3d_bg.jpg background (memory hog, "template" smell)
///      ✔ Removed BackdropFilter glass blur (GPU-heavy, outdated aesthetic)
///      ✔ Clean typography hierarchy with Inter
///      ✔ Brand identity front and center (GT purple + coral accent)
///      ✔ autofillHints for password manager support
///      ✔ Textfields use the theme — automatic dark-mode support
///      ✔ "Forgot password?" is a prominent link, not buried
///      ✔ Proper text keyboard + email keyboard types
///    Bugs:
///      ✔ Validators RETURN their result (was (v) { validator(v); } — no return)
///      ✔ onEditingComplete flows focus between fields
///      ✔ Submit is disabled while loading (prevents double-submit)
/// ════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInController());
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: AutofillGroup(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Form(
              key: controller.siginKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.massive),

                  // ─── Brand mark ──────────────────────────────
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_gt.png',
                        height: 40,
                        semanticLabel: 'Grant Thornton',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Text(
                        'Grant Thornton',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.huge),

                  // ─── Welcome copy ────────────────────────────
                  Text('Welcome back', style: theme.textTheme.displaySmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign in to continue reading the latest\nbusiness insights from Algeria.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.huge),

                  // ─── Email ───────────────────────────────────
                  TextFormField(
                    controller: controller.email,
                    validator: FieldsValidators.validatingEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email, AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@company.com',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ─── Password ────────────────────────────────
                  Obx(() => TextFormField(
                        controller: controller.password,
                        validator: (v) => FieldsValidators.validatingField('Password', v),
                        obscureText: controller.hidePassword.value,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => controller.signIn(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                controller.hidePassword.value = !controller.hidePassword.value,
                            icon: Icon(
                              controller.hidePassword.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            tooltip: controller.hidePassword.value
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                      )),

                  const SizedBox(height: AppSpacing.md),

                  // ─── Forgot password ─────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                      child: const Text('Forgot password?'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ─── Submit button ───────────────────────────
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.signIn,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      )),

                  const Spacer(),

                  // ─── Signup link ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const SignUpScreen()),
                          child: Text(
                            'Create one',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.brandCoral,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
