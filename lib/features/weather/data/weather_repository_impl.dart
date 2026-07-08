import '../../location/domain/coordinates.dart';
import '../domain/weather.dart';
import '../domain/weather_repository.dart';
import 'open_meteo_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._datasource);

  final OpenMeteoDatasource _datasource;

  @override
  Future<Weather> getWeather(Coordinates coordinates) {
    return _datasource.fetch(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    );
  }
}
