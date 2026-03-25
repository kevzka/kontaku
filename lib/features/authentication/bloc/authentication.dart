import 'package:flutter_bloc/flutter_bloc.dart';
import '../event-state/authentication-event-state.dart';
import '../login/data/loginFunc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationBloc({AuthenticationRepository? authenticationRepository})
    : _authenticationRepository =
          authenticationRepository ?? AuthenticationRepository(),
      super(AuthenticationInitial()) {
    // State awal

    // 1. Cek Status saat aplikasi mulai
    on<AuthenticationStatusChecked>((event, emit) async {
      emit(AuthenticationLoadInProgress());
      try {
        final user = await _authenticationRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      } catch (_) {
        emit(const Unauthenticated());
      }
    });

    // 2. Logic Login
    on<LoggedIn>((event, emit) async {
      emit(AuthenticationLoadInProgress()); // Tampilkan loading spinner
      try {
        // Panggil repository untuk login beneran
        final user = await _authenticationRepository.loginFunc(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(user)); // Sukses
      } catch (error) {
        emit(Unauthenticated(errorMessage: error.toString())); // Gagal
      }
    });

    // 3. Logic Logout
    on<LoggedOut>((event, emit) async {
      emit(AuthenticationLoadInProgress());
      await _authenticationRepository.logOut();
      emit(const Unauthenticated());
    });

    on<getCurrentUser>((event, emit) async {
      emit(AuthenticationLoadInProgress());
      try {
        final user = await _authenticationRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      } catch (_) {
        emit(const Unauthenticated());
      }
    });
  }
}
