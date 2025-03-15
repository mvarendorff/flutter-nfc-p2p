package com.example.flutter_nfc_p2p

import HceHostApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(HcePlugin())
        super.configureFlutterEngine(flutterEngine)
    }
}
