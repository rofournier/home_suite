import 'coordinates.dart';

abstract interface class LocationRepository {
  /// Position courante : GPS si autorisé, sinon repli (ville manuelle ou
  /// défaut). Ne jette jamais — renvoie toujours des coordonnées utilisables.
  Future<Coordinates> getCurrent();
}
