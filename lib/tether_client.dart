library bridge.tether.client;

// Core libraries
import 'dart:html';
import 'dart:async';

// Client side of library
import 'tether_shared.dart' hide Tether;
export 'tether_shared.dart' hide Tether;
import 'src/tether/client/tether.dart';
export 'src/tether/client/tether.dart';

part 'src/tether/client/client_socket_adapter.dart';
part 'src/tether/client/client_tether_maker.dart';

Tether tether;

Future globalTether() async {
  tether = await ClientTetherMaker.makeTether();
}