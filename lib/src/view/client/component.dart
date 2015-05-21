part of bridge.view.client;

abstract class Component extends VueComponent {

  String _template = '';

  final String templatePath = null;

  Tether _tether;

  Tether get tether => _tether;

  String get template => _template;

  _register(name, Tether tether) async {

    _tether = tether;

    Template viewTemplate = new Template(await tether.send('__||view', templatePath));

    _template = viewTemplate.templateMarkup;

    await register(name);
  }
}

Future renderView(Map<String, Component> components, Tether tether) async {

  var futures = <Future>[];

  components.forEach((name, component) => futures.add(component._register(name, tether)));

  await Future.wait(futures);

  new Vue(
  el: 'body'
  );
}