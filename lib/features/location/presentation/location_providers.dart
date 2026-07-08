import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/geolocator_location_repository.dart';
import '../domain/coordinates.dart';
import '../domain/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => const GeolocatorLocationRepository(),
);

/// Coordonnées courantes (GPS + repli). Écoutées par la météo.
final locationProvider = FutureProvider<Coordinates>(
  (ref) => ref.watch(locationRepositoryProvider).getCurrent(),
);
