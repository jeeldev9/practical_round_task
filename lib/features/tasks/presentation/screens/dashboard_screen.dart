import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/growth_progress_banner.dart';
import '../widgets/performance_stats.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/welcome_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          Obx(() {
            final user = authController.currentUser.value;
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.profile),
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          (user?.displayName ?? 'U')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Dynamic Welcome Header
              const WelcomeHeader(),

              const SizedBox(height: 24),

              // 2. Premium Gradient Banner
              const GrowthProgressBanner(),

              const SizedBox(height: 28),

              // 3. Stats Section
              const PerformanceStats(),

              const SizedBox(height: 28),

              // 4. Quick Actions
              const QuickActionsGrid(),

              const SizedBox(height: 32),

              // 5. Centered Sleek Logout Button
              ElevatedButton.icon(
                onPressed: () => authController.logout(),
                icon: const Icon(Icons.logout, size: 20),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.error,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
