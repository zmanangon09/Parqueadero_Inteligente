import 'package:geolocator/geolocator.dart';

abstract class LocationLocalDatasource {
  Future<(double lat, double lng)> getCurrentPosition();
}

class LocationLocalDatasourceImpl implements LocationLocalDatasource {
  @override
  Future<(double lat, double lng)> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const PermissionDeniedException('Permiso de ubicación denegado.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException(
        'Permiso de ubicación denegado permanentemente.',
      );
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return (pos.latitude, pos.longitude);
  }
}
