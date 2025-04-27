abstract class Failure {}

class UserFailure extends Failure {
  String message;
  UserFailure({required this.message});
}