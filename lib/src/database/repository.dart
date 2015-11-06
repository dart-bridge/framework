part of bridge.database;

class Repository<M> extends trestle.Repository<M> {
  final Events _events;
  Symbol __savedEventName;
  Symbol get _savedEventName =>
      __savedEventName ??= _getEventName('WasAdded');

  Symbol __deletedEventName;
  Symbol get _deletedEventName =>
      __deletedEventName ??= _getEventName('WasDeleted');

  Repository(this._events, Gateway gateway) : super(gateway);

  Symbol _getEventName(String suffix) {
    final modelName = MirrorSystem.getName(reflectClass(M).simpleName);
    return new Symbol('$modelName$suffix');
  }

  @override
  Future save(M model) {
    _events.fire(new ModelWasSaved<M>(model), as: _savedEventName);
    return super.save(model);
  }

  @override
  Future delete(M model) {
    _events.fire(new ModelWasDeleted<M>(model), as: _deletedEventName);
    return super.delete(model);
  }
}

class ModelEvent<M> {
  final M model;

  ModelEvent(M this.model);
}

class ModelWasSaved<M> extends ModelEvent<M> {
  ModelWasSaved(M model) : super(model);
}

class ModelWasDeleted<M> extends ModelEvent<M> {
  ModelWasDeleted(M model) : super(model);
}
