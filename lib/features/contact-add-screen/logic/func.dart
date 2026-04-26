import '../../authentication/logic/bloc/authentication.dart';
import '../../authentication/logic/event-state/authentication-event-state.dart';
import 'package:kontaku/core/models/number_model.dart';
import 'package:kontaku/core/utils/utils.dart';
import '../data/func.dart';

Future<bool> addContact({
  required String name,
  required String email,
  required String phone,
  required String notes,
  required AuthenticationBloc authenticationBloc,
}) async {
  final authenticationState = authenticationBloc.state;
  final currentUserUid = (authenticationState is Authenticated)
      ? authenticationState.user.uid
      : null;
  if (currentUserUid == null || currentUserUid.isEmpty) {
    return false;
  }
  try {
    final normalizedPhone = Kontaku.normalizePhoneNumber(phone);

    final NumberModel number = NumberModel(
      name: name,
      number: normalizedPhone,
      profilePath: null,
      email: email,
      notes: notes,
      uid: currentUserUid,
    );

    return addContactToFirestore(
      number: number,
      authenticationBloc: authenticationBloc,
    );
  } catch (e) {
    return false;
  }
}