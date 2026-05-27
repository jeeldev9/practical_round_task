import 'profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(String displayName) async {
    final cleanName = displayName.trim();
    if (cleanName.isEmpty) {
      throw 'Display name cannot be empty';
    }
    await repository.updateDisplayName(cleanName);
  }
}
