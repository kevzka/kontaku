import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- EVENTS (Input) ---
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
  @override
  List<Object> get props => [];
}

class AuthenticationStatusChecked extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String email;
  final String password;

  const LoggedIn({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoggedOut extends AuthenticationEvent {}

// --- STATES (Output) ---
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();
  @override
  List<Object> get props => [];

  get currentUser => null;
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoadInProgress extends AuthenticationState {}

class CurrentUserRequested extends AuthenticationEvent {}

class Authenticated extends AuthenticationState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthenticationState {
  final String? errorMessage;

  const Unauthenticated({this.errorMessage});

  @override
  List<Object> get props => [errorMessage ?? ''];
}
