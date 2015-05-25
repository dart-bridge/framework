part of bridge.view;

class RoutesDoNotMatchException extends BaseException {

  RoutesDoNotMatchException(String abstract, String absolute) : super('[$absolute] does not match route [$abstract]');
}
