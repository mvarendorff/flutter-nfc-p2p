package com.example.flutter_nfc_p2p

import HceHostApi
import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(HcePlugin())
        super.configureFlutterEngine(flutterEngine)
    }

    override fun onResume() {
        super.onResume()
        val adapter: NfcAdapter? = NfcAdapter.getDefaultAdapter(this)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this, 0, Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), PendingIntent.FLAG_IMMUTABLE)
        adapter?.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        val adapter: NfcAdapter? = NfcAdapter.getDefaultAdapter(this)
        adapter?.disableForegroundDispatch(this)
    }
}
