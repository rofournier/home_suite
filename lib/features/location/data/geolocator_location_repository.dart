import 'package:geolocator/geolocator.dart';

import '../domain/coordinates.dart';
import '../domain/location_repository.dart';

/// Localisation via GPS (geolocator). En cas de service coupé, permission
/// refusée ou erreur, repli silencieux sur [fallback].
class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository({this.fallback = _paris});

  final Coordinates fallback;

  static const _paris =
      Coordinates(latitude: 48.8566, longitude: 2.3522, label: 'Paris');

  @override
  Future<Coordinates> getCurrent() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return fallback;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) return fallback;

      final position = await Geolocator.getCurrentPosition();
      return Coordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return fallback;
    }
  }
}
