import 'package:kontaku/features/authentication/logic/bloc/authentication.dart';
import 'package:kontaku/features/authentication/logic/event-state/authentication-event-state.dart';

String checkAuthenticationStatus(AuthenticationBloc authenticationBloc) {
  final authenticationState = authenticationBloc.state;
  final currentUserUid = (authenticationState is Authenticated)
      ? authenticationState.user.uid
      : null;
  if (currentUserUid == null || currentUserUid.isEmpty) {
    return "";
  }
  return currentUserUid;
}