part of bridge.tether.shared;

class DefaultStructures {
  call(Tether tether) {
    tether.registerStructure('TetherException', TetherException, (m) => new TetherException(m));
  }
}
