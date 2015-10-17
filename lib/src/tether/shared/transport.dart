part of bridge.tether.shared;

typedef Session SessionReAttacher(List serialized);

SessionReAttacher transportSessionReAttacher;

void registerTetherTransport() {
  Serializer.instance.register('Session', Session,
      serialize: (Session o) {
        return [o.id, o.variables];
      }, deserialize: (List o) {
        if (transportSessionReAttacher != null)
          return transportSessionReAttacher(o);
        return new Session(o[0])..variables.addAll(o[1]);
      });
}
