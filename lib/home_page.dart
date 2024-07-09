import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'gsm_data_service.dart';
import 'firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Map<String, dynamic>>? gsmDataFuture;
  Position? initialPosition;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      setState(() {
        gsmDataFuture = gsmData();
        _startLocationUpdates();
      });
    });
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.phone,
      Permission.sms,
    ].request();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _startLocationUpdates() async {
    // Get initial position and GSM data immediately on load
    initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Map<String, dynamic> initialData = await gsmData();
    setState(() {
      gsmDataFuture = Future.value(initialData);
    });
    await addToFirestore(initialData);

    // Set up periodic updates
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (initialPosition != null && Geolocator.distanceBetween(
        initialPosition!.latitude,
        initialPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      ) > 30) {
        initialPosition = currentPosition;
        Map<String, dynamic> data = await gsmData();
        setState(() {
          gsmDataFuture = Future.value(data);
        });
        await addToFirestore(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: gsmDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              Map<String, dynamic> data = snapshot.data!;
              if (data.containsKey('error')) {
                return Text(data['error']);
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Device Model: ${data['device_model']}'),
                      Text('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(data['timestamp'])}'),
                      Text('Latitude: ${data['latitude']}'),
                      Text('Longitude: ${data['longitude']}'),
                      Text('Connectivity: ${data['connectivity']}'),
                      Text('RSSI: ${data['rssi']}'),
                      Text('RSRP: ${data['rsrp']}'),
                      Text('Level: ${data['level']}'),
                      Text('RAT: ${data['rat']}'),
                      Text('Network Type: ${data['networkType']}'),
                      Text('Phone Type: ${data['phoneType']}'),
                      Text('SIM Operator Name: ${data['simOperatorName']}'),
                      Text('SIM State: ${data['simState']}'),
                    ],
                  ),
                ),
              );
            } else {
              return const Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
