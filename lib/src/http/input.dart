part of bridge.http;

class Input implements Map<String, dynamic> {
  Map _data;

  Input(Map this._data);

  noSuchMethod(Invocation invocation) => reflect(_data).delegate(invocation);

  toString() {
    return 'Input(${_data.toString()})';
  }
}
