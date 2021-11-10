import 'package:app_settings/app_settings.dart';
import 'package:location/location.dart';

class CustomLocation {
  Future<LocationData> getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    } else if (_permissionGranted == PermissionStatus.deniedForever) {
      AppSettings.openLocationSettings();
    }

    _locationData = await location.getLocation();
    return _locationData;
  }
}
