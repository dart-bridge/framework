library bridge.tether.client;

import 'dart:async';
import 'dart:html';

import 'src/tether/client/tether.dart';
import 'tether_shared.dart' hide Tether;

export 'src/tether/client/tether.dart';
export 'tether_shared.dart' hide Tether;

part 'src/tether/client/client_socket_adapter.dart';
part 'src/tether/client/client_tether_maker.dart';

Tether tether;

Future globalTether() async {
  tether = await ClientTetherMaker.makeTether();
}