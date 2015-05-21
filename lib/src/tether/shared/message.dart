part of bridge.tether;

class Message {

  Message(String this.key, String this.token, this.data);

  factory Message.deserialize(String json) {

    Map data = JSON.decode(json);

    var msg = new Message(data['key'], data['token'], data['data']);

      msg._returnToken = data['returnToken'];

    return msg;
  }

  final String key;

  final String token;

  final dynamic data;

  String get serialized => JSON.encode({
    'key': key,
    'token': token,
    'data': data,
    'returnToken': returnToken,
  });

  String _returnToken;

  String get returnToken {

    if (_returnToken != null) return _returnToken;

    _returnToken = generateToken();

    return _returnToken;
  }

  static String generateToken() {

    var out = '';

    var rand = new Random();

    var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    while (out.length < 50) {

      out += chars[rand.nextInt(chars.length - 1)];
    }

    return out;
  }
}