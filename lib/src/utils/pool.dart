class Pool<T> {
  Set<int> _occupiedIds = {};
  List<T> items;

  Pool(this.items);

  IndexItem<T> fetch() {
    IndexItem<T>? item = _findFirstAvailableId();
    if(item == null) throw PoolExhaustedException();
    return item;
  }

  void release(int id) {
    _occupiedIds.remove(id);
  }

  IndexItem<T>? _findFirstAvailableId() {
    for(int i=0; i< items.length; i++) {
      if(this._occupiedIds.contains(i)) {
        continue;
      } else {
        _occupiedIds.add(i);
        return IndexItem(i, items[i]);
      }
    }
    return null;
  }

}

class IndexItem<T> {
  int id;
  T item;

  IndexItem(this.id, this.item);
}

class PoolExhaustedException implements Exception {
  String message = "Not Item left.";

  @override
  String toString() {
    return "PoolExhaustedException: $message";
  }
}