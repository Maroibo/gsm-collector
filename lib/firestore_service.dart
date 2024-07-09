import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> addToFirestore(Map<String, dynamic> data) async {
  CollectionReference gsmDataCollection = FirebaseFirestore.instance.collection('gsm_data');

  try {
    // Print the types of data to ensure they are correct for every attribute
    await gsmDataCollection.add({
      'device_model': data['device_model'],
      'timestamp': Timestamp.fromMillisecondsSinceEpoch(data['timestamp']),
      'network_type': data['networkType'],
      'phone_type': data['phoneType'],
      'sim_operator_name': data['simOperatorName'],
      'sim_state': data['simState'],
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'connectivity': data['connectivity'],
      'rssi': data['rssi'],
      'rsrp': data['rsrp'],
      'level': data['level'],
      'rat': data['rat'],
    });

    // After successfully adding to Firestore, check for any stored local data
    await _retryLocalData(gsmDataCollection);
  } catch (error) {
    print("Failed to add data to Firestore: $error");

    // Save to local storage if Firestore update fails
    await _saveDataLocally(data);
  }
}

Future<void> _saveDataLocally(Map<String, dynamic> data) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String>? localDataList = prefs.getStringList('local_gsm_data') ?? [];

    localDataList.add(jsonEncode(data));
    await prefs.setStringList('local_gsm_data', localDataList);

  } catch (error) {
    print("Failed to save data locally: $error");
    // Handle local storage failure if necessary
  }
}

Future<void> _retryLocalData(CollectionReference gsmDataCollection) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String>? localDataList = prefs.getStringList('local_gsm_data') ?? [];

    if (localDataList.isNotEmpty) {
      for (String dataString in localDataList) {
        Map<String, dynamic> data = jsonDecode(dataString);

        try {
          await gsmDataCollection.add({
            'device_model': data['device_model'],
            'timestamp': Timestamp.fromMillisecondsSinceEpoch(data['timestamp']),
            'network_type': data['network_type'],
            'phone_type': data['phone_type'],
            'sim_operator_name': data['sim_operator_name'],
            'sim_state': data['sim_state'],
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'connectivity': data['connectivity'],
            'rssi': data['rssi'],
            'rsrq': data['rsrq'],
            'level': data['level'],
            'rat': data['rat'],
          });
          print("Retried data added to Firestore: ${data['timestamp']}");
        } catch (error) {
          print("Failed to add retried data to Firestore: $error");
          // If any retry fails, we leave the remaining data in local storage
          return;
        }
      }

      // Clear local storage if all retries are successful
      await prefs.remove('local_gsm_data');
    }
  } catch (error) {
    print("Failed to retry local data upload: $error");
    // Handle retry failure if necessary
  }
}
