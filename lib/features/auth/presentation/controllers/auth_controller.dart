import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../domain/auth_repository.dart';
import '../../domain/forgot_password_usecase.dart';
import '../../domain/login_usecase.dart';
import '../../domain/register_usecase.dart';
import '../../domain/user_entity.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final AuthRepository authRepository;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
    required this.authRepository,
  });

  // Reactive Variables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);

  // TextEditingControllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // FocusNodes
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final nameFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  // Monitor auth state changes and perform custom routing
  void _checkAuthState() {
    authRepository.authStateChanges.listen((UserEntity? user) async {
      currentUser.value = user;
      final String currentRoute = Get.currentRoute;

      if (user != null) {
        // Logged in: enforce minimum splash visibility before navigating
        if (currentRoute == AppRoutes.splash ||
            currentRoute == AppRoutes.login ||
            currentRoute == AppRoutes.register ||
            currentRoute.isEmpty) {
          if (currentRoute == AppRoutes.splash || currentRoute.isEmpty) {
            // Guarantee splash is visible for at least 2.5 seconds
            await Future.delayed(const Duration(milliseconds: 2000));
          }
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        // Logged out: fallback to login page
        if (currentRoute != AppRoutes.login &&
            currentRoute != AppRoutes.register &&
            currentRoute != AppRoutes.forgotPassword &&
            currentRoute != AppRoutes.splash) {
          Get.offAllNamed(AppRoutes.login);
        } else if (currentRoute == AppRoutes.splash || currentRoute.isEmpty) {
          // Guarantee splash is visible before going to login too
          await Future.delayed(const Duration(milliseconds: 2000));
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }

  // Login handler
  Future<void> login() async {
    isLoading.value = true;
    clearError();

    try {
      final user = await loginUseCase(
        emailController.text,
        passwordController.text,
      );
      currentUser.value = user;
      clearFields();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Register handler
  Future<void> register() async {
    isLoading.value = true;
    clearError();

    try {
      final user = await registerUseCase(
        nameController.text,
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
      );
      currentUser.value = user;
      clearFields();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password handler
  Future<void> forgotPassword() async {
    isLoading.value = true;
    clearError();

    try {
      await forgotPasswordUseCase(emailController.text);
      FocusManager.instance.primaryFocus?.unfocus();
      Get.snackbar(
        'Success',
        'Password reset email sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Logout handler
  Future<void> logout() async {
    try {
      await authRepository.logout();
      currentUser.value = null;
      clearFields();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to log out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggles
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void clearError() {
    errorMessage.value = '';
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();

    emailFocus.dispose();
    passwordFocus.dispose();
    nameFocus.dispose();
    confirmPasswordFocus.dispose();

    super.onClose();
  }
}
