library bridge.tether.client.tether;

import 'dart:async';
import '../../../tether_shared.dart';
import '../../../http_shared.dart';

class Tether extends TetherBase {
  Tether(Session session, Messenger messenger) : super(session, messenger);

  Future applyData(data, Function listener) async {
    if (data == null)
      return listener();
    else
      return listener(data);
  }
}
