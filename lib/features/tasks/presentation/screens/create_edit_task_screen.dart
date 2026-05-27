import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/task_controller.dart';
import '../../domain/task_entity.dart';
import '../widgets/task_priority_selector.dart';

class CreateEditTaskScreen extends StatefulWidget {
  const CreateEditTaskScreen({super.key});

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final TaskController controller = Get.find<TaskController>();
  late final FocusNode _titleFocus;
  late final FocusNode _descriptionFocus;

  @override
  void initState() {
    super.initState();
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this is an "Edit" operation by checking route arguments
    final TaskEntity? task = Get.arguments as TaskEntity?;
    final isEditing = task != null;

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
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Modify your assignment' : 'Add a new assignment',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Task Title Input
              AuthTextField(
                controller: controller.titleController,
                label: 'Task Title',
                prefixIcon: Icons.title,
                textInputAction: TextInputAction.next,
                focusNode: _titleFocus,
                nextFocusNode: _descriptionFocus,
              ),

              const SizedBox(height: 16),

              // 2. Task Description Input (multiline)
              TextField(
                controller: controller.descriptionController,
                focusNode: _descriptionFocus,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 50.0),
                    child: Icon(Icons.description_outlined),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Priority Level Selector (Low, Medium, High Buttons)
              const TaskPrioritySelector(),

              const SizedBox(height: 20),

              // 4. Due Date Picker TextField
              Text(
                'Due Date (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.dueDateController,
                readOnly: true,
                onTap: () => _openDatePicker(context),
                decoration: InputDecoration(
                  labelText: 'Choose Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Action Button
              Obx(() => AppButton(
                    text: isEditing ? 'Update Task' : 'Create Task',
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.saveTask(task),
                  )),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final first = now.subtract(const Duration(days: 365));
    final last = now.add(const Duration(days: 365 * 5));

    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDueDate.value ?? now,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              primaryContainer: AppColors.primaryLight,
              onPrimaryContainer: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectDueDate(picked);
    }
  }
}

