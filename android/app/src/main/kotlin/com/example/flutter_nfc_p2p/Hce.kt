package com.example.flutter_nfc_p2p;

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import io.flutter.Log

fun ByteArray.toHex(): String = joinToString(separator = "") { eachByte -> "%02x".format(eachByte) }

class Hce : HostApduService() {
    companion object {
        lateinit var instance: Hce
    }

    init {
        instance = this
    }

    // We don't really care about the actual Apdu for now since it doesn't contain anything relevant
    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray? {
        val commandHex = commandApdu.toHex()
        Log.i("P2P", "Received apdu $commandHex, processing...")
        if (commandHex.startsWith("00a40400")) {
            HceState.isConnected = true
            return byteArrayOf(0x90.toByte(), 0x00)
        }

        if (HceState.message != null) {
            Log.i("P2P", "We have a message, so we send that!")
            HceState.hasSent = true
            HceState.callback?.invoke(Result.success(Unit))
            val messageApdu = HceState.getMessageApdu()
            Log.i("P2P", "Sending apdu ${messageApdu.toHex()}")
            return messageApdu
        }

        return null
    }

    override fun onDeactivated(reason: Int) {
        Log.i("P2P", "HostApduService deactivated with code $reason")
        HceState.message = null
        HceState.isConnected = false
        HceState.hasSent = false
        HceState.callback = null
    }
}
