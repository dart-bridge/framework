part of bridge.tether;

void resolveTetherListener(Tether tether, String key, Function listener) {
  tether.listen(key, (i) => _helperContainer.resolve(listener, injecting: {
    http.Input: i is Map ? new http.Input(i) : new http.Input({'data': i})
  }));
}