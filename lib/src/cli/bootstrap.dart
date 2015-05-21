part of bridge.cli;

bootstrap(List<String> arguments, message, Type bridge) {

  var program = new BridgeCli(bridge);

  program.run(arguments, message);
}