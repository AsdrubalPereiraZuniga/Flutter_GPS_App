import 'package:geolocator/geolocator.dart';

class LocationService {    
  
  /// Solicitamos el permiso al usuario para habilitar la ubicación del dispositivo
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  /// Verificamos si el servicio de ubicación está habilitado
  Future<bool> isServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  /// Obtenemos la ubicación actual del dispositivo
  Future<Position> getCurrentLocation() async {

    /// Verificamos si el servicio de ubicación está habilitado
    bool serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) {
      // Si el servicio no está habilitado, solicitamos al usuario que lo active
      bool result = await Geolocator.openLocationSettings();
      if (!result) {
        throw Exception('El servicio de ubicación no está habilitado');
      }
    }

    /// Verificamos y solicitamos el permiso de ubicación si no está concedido
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado de forma permanente');
    }

    // Obtenemos la ubicación actual del dispositivo
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
