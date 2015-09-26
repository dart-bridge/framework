part of bridge.database;

class Repository<M> extends trestle.Repository<M> {
  Events _events;
  Symbol __addedEventName;

  Symbol get _addedEventName => __addedEventName ??= _getEventName('WasAdded');
  Symbol __updatedEventName;

  Symbol get _updatedEventName =>
      __updatedEventName ??= _getEventName('WasUpdated');
  Symbol __deletedEventName;

  Symbol get _deletedEventName =>
      __deletedEventName ??= _getEventName('WasDeleted');

  Repository(Events this._events) {
    super.connect(_gateway);
  }

  Symbol _getEventName(String suffix) {
    final modelName = MirrorSystem.getName(reflectClass(M).simpleName);
    return new Symbol('$modelName$suffix');
  }

  @override
  Future add(M model) {
    _events.fire(new ModelWasAdded<M>(model), as: _addedEventName);
    return super.add(model);
  }

  @override
  Future delete(M model) {
    _events.fire(new ModelWasDeleted<M>(model), as: _deletedEventName);
    return super.delete(model);
  }

  @override
  Future update(M model) {
    _events.fire(new ModelWasUpdated<M>(model), as: _updatedEventName);
    return super.update(model);
  }
}

class ModelEvent<M> {
  final M model;

  ModelEvent(M this.model);
}

class ModelWasAdded<M> extends ModelEvent<M> {
  ModelWasAdded(M model) : super(model);
}

class ModelWasDeleted<M> extends ModelEvent<M> {
  ModelWasDeleted(M model) : super(model);
}

class ModelWasUpdated<M> extends ModelEvent<M> {
  ModelWasUpdated(M model) : super(model);
}
