part of bridge.cli;

class BridgeCli extends Program {

  Application app;

  BridgeCli(Type bridge) {

    app = new Application(bridge);

    app.singleton(this);
  }

  setUp() async {

    print('Welcome to the Bridge CLI!');

    await app.setUp('config');

    this.displayHelp();

    this.shell.prompter = () => '~> ';
  }

  tearDown() async {
    await app.tearDown();
  }
}
