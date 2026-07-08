import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/auth/data/auth_api.dart';
import 'package:home_sweet_home/features/auth/data/auth_repository_impl.dart';
import 'package:home_sweet_home/features/auth/data/session_store.dart';
import 'package:home_sweet_home/features/auth/domain/session.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class InMemorySessionStore implements SessionStore {
  String? raw;

  @override
  Future<String?> readRaw() async => raw;
  @override
  Future<void> write(Session session) async =>
      raw = jsonEncode(session.toJson());
  @override
  Future<void> clear() async => raw = null;
}

Map<String, dynamic> sessionJson({String name = 'Flo'}) => {
      'token': 'jwt-123',
      'user': {
        'id': 'u1',
        'email': 'f@t.fr',
        'displayName': name,
        'householdId': 'h1',
      },
      'household': {
        'id': 'h1',
        'name': 'Maison',
        'joinCode': 'ABC123',
        'members': [
          {'id': 'u1', 'displayName': name},
        ],
      },
    };

AuthRepositoryImpl repo(InMemorySessionStore store,
    Future<http.Response> Function(http.Request) handler) {
  return AuthRepositoryImpl(
    api: AuthApi(baseUrl: 'http://x', client: MockClient(handler)),
    store: store,
  );
}

http.Response ok(Object body) => http.Response(jsonEncode(body), 200,
    headers: {'content-type': 'application/json'});

void main() {
  test('restore hors ligne → session en cache (pas de déconnexion)', () async {
    final store = InMemorySessionStore()
      ..raw = jsonEncode(sessionJson(name: 'Cache'));
    final r = repo(store, (_) async => throw const SocketException('down'));

    final session = await r.restore();

    expect(session, isNotNull);
    expect(session!.user.displayName, 'Cache');
    expect(store.raw, isNotNull); // cache conservé
  });

  test('restore avec jeton refusé (401) → déconnecté, cache purgé', () async {
    final store = InMemorySessionStore()..raw = jsonEncode(sessionJson());
    final r = repo(store,
        (_) async => http.Response('{"error":"Session invalide"}', 401));

    expect(await r.restore(), isNull);
    expect(store.raw, isNull);
  });

  test('restore en ligne → session rafraîchie et cache mis à jour', () async {
    final store = InMemorySessionStore()
      ..raw = jsonEncode(sessionJson(name: 'Vieux'));
    final fresh = sessionJson(name: 'Frais')..remove('token');
    final r = repo(store, (_) async => ok(fresh));

    final session = await r.restore();

    expect(session!.user.displayName, 'Frais');
    expect(store.raw, contains('Frais'));
  });

  test('jeton nu hérité + en ligne → session reconstruite et mise en cache',
      () async {
    final store = InMemorySessionStore()..raw = 'jwt-legacy';
    final me = sessionJson()..remove('token');
    final r = repo(store, (request) async {
      expect(request.headers['authorization'], 'Bearer jwt-legacy');
      return ok(me);
    });

    final session = await r.restore();

    expect(session, isNotNull);
    expect(decodeStoredSession(store.raw!), isNotNull); // migré en JSON
  });

  test('jeton nu hérité + hors ligne → null (relogin nécessaire une fois)',
      () async {
    final store = InMemorySessionStore()..raw = 'jwt-legacy';
    final r = repo(store, (_) async => throw const SocketException('down'));

    expect(await r.restore(), isNull);
  });

  test('login persiste la session complète (JSON, pas un jeton nu)', () async {
    final store = InMemorySessionStore();
    final r = repo(store, (_) async => ok(sessionJson()));

    await r.login(email: 'f@t.fr', password: 'secret1');

    final cached = decodeStoredSession(store.raw!);
    expect(cached!.token, 'jwt-123');
    expect(cached.household.joinCode, 'ABC123');
  });

  test('logout purge le cache', () async {
    final store = InMemorySessionStore()..raw = jsonEncode(sessionJson());
    final r = repo(store, (_) async => ok({}));

    await r.logout();
    expect(store.raw, isNull);
  });
}
