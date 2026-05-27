import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your details below',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 32),

              // Full Name TextField
              AuthTextField(
                controller: controller.nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                focusNode: controller.nameFocus,
                nextFocusNode: controller.emailFocus,
              ),

              const SizedBox(height: 16),

              // Email TextField
              AuthTextField(
                controller: controller.emailController,
                label: 'Email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                focusNode: controller.emailFocus,
                nextFocusNode: controller.passwordFocus,
              ),

              const SizedBox(height: 16),

              // Password TextField with Eye Toggle
              Obx(() => AuthTextField(
                    controller: controller.passwordController,
                    label: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !controller.isPasswordVisible.value,
                    textInputAction: TextInputAction.next,
                    focusNode: controller.passwordFocus,
                    nextFocusNode: controller.confirmPasswordFocus,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  )),

              const SizedBox(height: 16),

              // Confirm Password TextField with Eye Toggle
              Obx(() => AuthTextField(
                    controller: controller.confirmPasswordController,
                    label: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    textInputAction: TextInputAction.done,
                    focusNode: controller.confirmPasswordFocus,
                    onSubmitted: () => controller.register(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  )),

              const SizedBox(height: 24),

              // Error message Obx wrapper
              Obx(() {
                if (controller.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              Obx(() => SizedBox(
                  height: controller.errorMessage.value.isNotEmpty ? 16 : 0)),

              // Register Button with Obx loading indicator
              Obx(() => AppButton(
                    text: 'Sign Up',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.register(),
                  )),

              const SizedBox(height: 24),

              // Already have an account? Sign In TextButton
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
