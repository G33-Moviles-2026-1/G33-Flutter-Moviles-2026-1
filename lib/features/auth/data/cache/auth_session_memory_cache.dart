import 'package:andespace/core/cache/lru_cache.dart';
import 'package:andespace/features/auth/domain/entities/auth_user.dart';

class AuthSessionMemoryCache {
  AuthSessionMemoryCache({int capacity = 3}) : _cache = LruCache(capacity);

  final LruCache<String, AuthUser> _cache;

  AuthUser? get(String email) => _cache.get(email.trim().toLowerCase());

  void put(AuthUser user) {
    _cache.put(user.email.trim().toLowerCase(), user);
  }

  AuthUser? get mostRecent {
    final entries = _cache.entries.toList();
    return entries.isEmpty ? null : entries.last.value;
  }

  void clear() => _cache.clear();
}
