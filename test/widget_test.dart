import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/app/destinations.dart';

void main() {
  test('chaque destination a une route unique commençant par /', () {
    final routes = AppDestination.values.map((d) => d.route).toList();
    expect(routes.toSet().length, routes.length, reason: 'routes dupliquées');
    expect(routes.every((r) => r.startsWith('/')), isTrue);
  });
}
