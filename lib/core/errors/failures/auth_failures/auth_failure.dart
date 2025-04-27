abstract class Failure {}

class AuthFailure extends Failure {
  String code;
  String message;
  AuthFailure({required this.message,required this.code});
}
