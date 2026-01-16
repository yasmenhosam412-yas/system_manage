part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Signup States
class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded extends AuthState {
  final String message;

  const AuthLoaded(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}

// Login States
class AuthLoginLoading extends AuthState {}

class AuthLoginLoaded extends AuthState {
  final String message;

  const AuthLoginLoaded(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthLoginError extends AuthState {
  final String error;

  const AuthLoginError(this.error);

  @override
  List<Object?> get props => [error];
}

// Forgot Password States
class AuthForgotLoading extends AuthState {}

class AuthForgotEmailSent extends AuthState {
  final String message;

  const AuthForgotEmailSent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthForgotError extends AuthState {
  final String error;

  const AuthForgotError(this.error);

  @override
  List<Object?> get props => [error];
}
