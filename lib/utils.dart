import 'package:telephony/telephony.dart';

// Function to map signal strength to a score from 1 to 10
int mapSignalStrengthToScore(SignalStrength signalStrength) {
  // Adjust according to actual properties of SignalStrength class
  String signalValue = signalStrength.toString().split('.').last;  // Assuming the correct property for signal strength

  switch (signalValue) {
    case 'GREAT':
      return 10;  // Excellent signal
    case 'GOOD':
      return 7;  // Good signal
    case 'MODERATE':
      return 5;  // Moderate signal
    case 'POOR':
      return 3;  // Poor signal
    case 'NONE_OR_UNKNOWN':
    default:
      return 1;  // Very poor signal
  }
}
