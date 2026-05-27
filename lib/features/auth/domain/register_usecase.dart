import 'auth_repository.dart';
import 'user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw 'Full name cannot be empty';
    }

    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw 'Email address cannot be empty';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      throw 'Please enter a valid email address';
    }

    if (password.isEmpty) {
      throw 'Password cannot be empty';
    }

    if (password.length < 6) {
      throw 'Password must be at least 6 characters long';
    }

    if (confirmPassword.isEmpty) {
      throw 'Please confirm your password';
    }

    if (password != confirmPassword) {
      throw 'Passwords do not match';
    }

    return repository.register(cleanEmail, password, cleanName);
  }
}
