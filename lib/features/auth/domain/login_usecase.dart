import 'auth_repository.dart';
import 'user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) async {
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

    return repository.login(cleanEmail, password);
  }
}
