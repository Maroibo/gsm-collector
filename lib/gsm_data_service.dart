import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'utils.dart';

Future<Map<String, dynamic>> gsmData() async {
  const platform = MethodChannel('com.example.signalinfo');

  try {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final DateTime timestamp = DateTime.now();
    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());

    final Map<String, dynamic> data = {
      'device_model': androidInfo.model,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'connectivity': connectivityResult.toString().split('.').last,
    };

    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getTelephonyData');

      data['rssi'] = result['rssi'];
      data['rsrp'] = result['rsrp'];
      data['level'] = result['level'];
      data['rat'] = result['rat'];
      data['networkType'] = result['networkType'];
      data['phoneType'] = result['phoneType'];
      data['simOperatorName'] = result['simOperatorName'];
      data['simState'] = result['simState'];
    } on PlatformException catch (e) {
      print('Error fetching data from platform channel: ${e.message}');
      return {'error': 'Error fetching data: ${e.message}'};
    }
    return data;
  } catch (e) {
    print('Error fetching GSM data: $e');
    return {'error': 'Error fetching GSM data: $e'};
  }
}
