part of bridge.view.shared;

void registerViewTransport() {
  serializer.register('bridge.view.Template', Template,
      serialize: (Template template) => [
        template.content, template.data
      ],
      deserialize: (List serialized) =>
      new Template(serialized[0], data: serialized[1]));
}
