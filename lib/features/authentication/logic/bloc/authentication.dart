import 'package:flutter_bloc/flutter_bloc.dart';
import '../event-state/authentication-event-state.dart';
import '../../login/data/loginFunc.dart';

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
        final email = event.email.trim();
        final password = event.password;

        if (email.isEmpty || password.isEmpty) {
          emit(const Unauthenticated(errorMessage: 'Email dan password wajib diisi'));
          return;
        }

        // Panggil repository untuk login beneran
        final user = await _authenticationRepository.login(
          email: email,
          password: password,
        );
        emit(Authenticated(user)); // Sukses
      } catch (error) {
        emit(Unauthenticated(errorMessage: error.toString())); // Gagal
      }
    });

    // 3. Logic Logout
    on<LoggedOut>((event, emit) async {
      emit(AuthenticationLoadInProgress());
      try {
        await _authenticationRepository.logout();
        emit(const Unauthenticated());
      } catch (error) {
        emit(Unauthenticated(errorMessage: error.toString()));
      }
    });

    on<CurrentUserRequested>((event, emit) async {
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
