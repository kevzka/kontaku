abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, this.code);

  @override
  String toString() => code == null ? message : '$code: $message';
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Terjadi kesalahan pada server',
    super.code,
  ]) : super();
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Koneksi internet bermasalah',
    super.code,
  ]) : super();
}

class CacheException extends AppException {
  const CacheException([
    super.message = 'Gagal mengambil data lokal',
    super.code,
  ]) : super();
}

class AuthException extends AppException {
  const AuthException([
    super.message = 'Autentikasi gagal',
    super.code,
  ]) : super();
}

class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Data tidak valid',
    super.code,
  ]) : super();
}