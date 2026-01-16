import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_manage/services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthInitial());

  Future<void> createAccount(
    String email,
    String password,
    String title,
    String? imagePath,
  ) async {
    emit(AuthLoading());
    final result = await authService.signup(email, password, title, imagePath);
    result.fold(
      (error) => emit(AuthError(error)),
      (message) => emit(AuthLoaded(message)),
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoginLoading());
    final result = await authService.login(email, password);
    result.fold(
      (error) => emit(AuthLoginError(error)),
      (message) => emit(AuthLoginLoaded(message)),
    );
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthForgotLoading());
    final result = await authService.sendPasswordResetEmail(email);
    result.fold(
      (error) => emit(AuthForgotError(error)),
      (_) => emit(
        const AuthForgotEmailSent("Password reset email sent successfully."),
      ),
    );
  }
}
