part of bridge.test;

class _InputOutput extends SilentInputDevice implements OutputDevice {
  final log = <String>[];

  void output(Output output) {
    log.add(output.plain);
  }

  Future close() async {}
}
