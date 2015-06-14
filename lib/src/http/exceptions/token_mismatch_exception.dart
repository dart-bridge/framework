part of bridge.http;

class TokenMismatchException extends BaseException {
  TokenMismatchException() : super('Cross site request forgery prevented');
}
