abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, this.code);

  @override
  String toString() => code == null ? message : '$code: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Terjadi kesalahan pada server',
    super.code,
  ]) : super();
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([
    super.message = 'Koneksi internet bermasalah',
    super.code,
  ]) : super();
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Data lokal tidak tersedia',
    super.code,
  ]) : super();
}

class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Autentikasi gagal',
    super.code,
  ]) : super();
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Data tidak valid',
    super.code,
  ]) : super();
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Terjadi kesalahan yang tidak diketahui',
    super.code,
  ]) : super();
}