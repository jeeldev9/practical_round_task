import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/update_profile_usecase.dart';

class ProfileController extends GetxController {
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthController authController;

  ProfileController({
    required this.updateProfileUseCase,
    required this.authController,
  });

  // Reactive Variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // TextEditingControllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  // Populates inputs from current authentications state
  void _loadUserProfile() {
    final user = authController.currentUser.value;
    if (user != null) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email;
    }
  }

  // Updates display name and refreshes active AuthController session
  Future<void> updateProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final cleanName = nameController.text.trim();
      await updateProfileUseCase(cleanName);

      // Refresh global session inside AuthController reactively
      final currentUserVal = authController.currentUser.value;
      if (currentUserVal != null) {
        authController.currentUser.value = currentUserVal.copyWith(
          displayName: cleanName,
        );
      }

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(); // Returns to Settings screen
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
