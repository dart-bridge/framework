part of bridge.tether;

class Tether {

  TetherContainer _container;

  String _token;

  String get token => _token;

  Future get onConnectionLost => _container.onConnectionEnd;

  Tether(String this._token, TetherContainer this._container) {

    this.listen('_pingpong', (_) async {

      await new Future.delayed(new Duration(seconds: 5));

      if (!_container._socketIsOpen) return;

      this.send('_pingpong', null);
    });
  }

  void initiatePersistentConnection() {

    this.send('_pingpong', null);
  }

  Future send(String key, [data]) async {

    var message = new Message(
        key, _token, data
    );

    Message returnValue = await _container.send(message);

    return returnValue.data;
  }

  Future listen(String key, Future listener(data)) async {

    Stream<Message> stream = _container.listen(key);

    stream.listen((Message message) async {

      var returnValue = await listener(message.data);

      send(message.returnToken, returnValue);
    });
  }
}