import 'dart:collection';

class LruCache<K, V> {
  LruCache(this.capacity) : assert(capacity > 0, 'capacity must be > 0');

  final int capacity;
  final LinkedHashMap<K, V> _map = LinkedHashMap();

  int get length => _map.length;
  bool get isEmpty => _map.isEmpty;

  V? get(K key) {
    if (!_map.containsKey(key)) return null;
    final value = _map.remove(key) as V;
    _map[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= capacity) {
      _map.remove(_map.keys.first); // evict LRU entry
    }
    _map[key] = value;
  }

  Iterable<MapEntry<K, V>> get entries => _map.entries;

  bool containsKey(K key) => _map.containsKey(key);

  void remove(K key) => _map.remove(key);

  void clear() => _map.clear();
}
