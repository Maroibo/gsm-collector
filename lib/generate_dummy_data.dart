import 'package:faker/faker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_helper.dart';

Future<void> generateDummyData(int numberOfEntries, double centerLat, double centerLong, double radius) async {
  final faker = Faker();
  final CollectionReference gsmDataCollection = FirebaseFirestore.instance.collection('gsm-data-gen');

  for (int i = 0; i < numberOfEntries; i++) {
    final location = LocationHelper.generateRandomLocation(centerLat, centerLong, radius);

    // Generate signal score between 1 and 10
    final signalScore = faker.randomGenerator.integer(10, min: 1);

    // Simulate RSSI and RSRP values within a reasonable range
    final rssi = faker.randomGenerator.integer(-30,min: -110);
    final rsrp = faker.randomGenerator.integer(-44,min: -140);

    final data = {
      'device_model': 'Device Model XYZ',
      'timestamp': DateTime.now(),
      'network_type': 'LTE',
      'phone_type': 'GSM',
      'sim_operator_name': 'Vodafone',
      'signal_score': signalScore,
      'rssi': rssi,
      'rsrp': rsrp,
      'level': faker.randomGenerator.integer(5,min: 0), // Generates level from 0 to 5
      'latitude': location['latitude'],
      'longitude': location['longitude'],
    };

    await gsmDataCollection.add(data);
    print("Added dummy data entry: $data");
  }
}
