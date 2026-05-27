import 'auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw 'Email address cannot be empty';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      throw 'Please enter a valid email address';
    }

    return repository.forgotPassword(cleanEmail);
  }
}
