library bridge.transport.shared;

import 'package:tether/protocol.dart' as tether;

part 'src/transport/serializer.dart';

Serializer get serializer => Serializer.instance;
