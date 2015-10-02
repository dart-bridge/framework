part of bridge.view.shared;

void registerViewTransport() {
  Serializer.instance.register('Template', Template,
      serialize: (Template o) {
        return [o.data, o.parsed];
      }, deserialize: (List o) {
        return new Template(data: o[0], parsed: o[1]);
      });
}
