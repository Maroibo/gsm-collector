package com.example.gsm_project

import android.content.Context
import android.os.Build
import android.telephony.CellInfo
import android.telephony.CellInfoLte
import android.telephony.CellSignalStrengthLte
import android.telephony.SignalStrength
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.signalinfo"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d("MainActivity", "Configuring Flutter Engine")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "Method call received: ${call.method}")
            if (call.method == "getTelephonyData") {
                val data = getTelephonyData()
                result.success(data)
                Log.d("MainActivity", "Telephony data sent: $data")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getTelephonyData(): Map<String, Any?> {
        val data = mutableMapOf<String, Any?>()
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val signalStrength: SignalStrength? = telephonyManager.signalStrength
            signalStrength?.let {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val cellInfoList: List<CellInfo> = telephonyManager.allCellInfo
                    for (cellInfo in cellInfoList) {
                        if (cellInfo is CellInfoLte) {
                            val cellSignalStrengthLte: CellSignalStrengthLte = cellInfo.cellSignalStrength
                            data["rssi"] = cellSignalStrengthLte.rssi
                            data["rsrp"] = cellSignalStrengthLte.rsrp
                            data["level"] = cellSignalStrengthLte.level
                            data["rat"] = 14 // LTE typically corresponds to 14 in RAT
                            Log.d("LTE Data", data.toString())
                        }
                    }
                } else {
                    // For API levels below Q
                    val lteSignalStrength: CellSignalStrengthLte? = it.getCellSignalStrengths(CellSignalStrengthLte::class.java).firstOrNull()
                    lteSignalStrength?.let { cellSignalStrengthLte ->
                        data["rssi"] = cellSignalStrengthLte.rssi
                        data["rsrp"] = cellSignalStrengthLte.rsrp
                        data["level"] = cellSignalStrengthLte.level
                        Log.d("LTE Data", data.toString())
                    }
                }
            }
        }

        data["networkType"] = telephonyManager.networkType // Usually available
        data["phoneType"] = telephonyManager.phoneType // Usually available
        data["simOperatorName"] = telephonyManager.simOperatorName // Usually available
        data["simState"] = telephonyManager.simState // Usually available

        Log.d("TelephonyData", data.toString())
        return data
    }
}
