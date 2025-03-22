package com.example.flutter_nfc_p2p

import HceHostApi
import android.app.Activity
import android.content.Intent
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class HcePlugin : FlutterPlugin, HceHostApi, ActivityAware {
    private var activity: Activity? = null

    override fun exposeMessage(message: String, callback: (Result<Unit>) -> Unit) {
        Log.i("P2P", "Exposing message $message")
        HceState.message = message;
        HceState.callback = callback;

        if (HceState.isConnected && !HceState.hasSent) {
            Log.i("P2P", "Hce is connected and hasn't sent, so we send through the instance");
            HceState.hasSent = true
            Hce.instance.sendResponseApdu(HceState.getMessageApdu())
            callback(Result.success(Unit))
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        activity?.startService(Intent(activity?.baseContext, Hce::class.java))

        HceHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}