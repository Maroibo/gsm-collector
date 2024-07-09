import 'package:workmanager/workmanager.dart';
import 'gsm_data_service.dart';
import 'firestore_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.none) {
      Map<String, dynamic> data = await gsmData();
      await addToFirestore(data);
    } else {
      print("No internet connection. Data will be stored locally.");
    }

    return Future.value(true);
  });
}
