package com.example.flutter_nfc_p2p;

import HceHostApi
import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import java.nio.charset.StandardCharsets

class Hce : HceHostApi, HostApduService() {
    private var message: String? = null
    private var isConnected: Boolean = false
    private var hasSent: Boolean = false
    private var callback: ((Result<Unit>) -> Unit)? = null

    companion object {
        lateinit var instance: Hce
    }

    init {
        instance = this
    }

    override fun exposeMessage(message: String, callback: (Result<Unit>) -> Unit) {
        this.message = message;
        this.callback = callback;

        if (isConnected && !hasSent) {
            hasSent = true
            sendResponseApdu(getMessageApdu())
            callback(Result.success(Unit))
        }
    }

    // We don't really care about the actual Apdu for now since it doesn't contain anything relevant
    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray? {
        isConnected = true
        if (message != null) {
            hasSent = true
            callback?.invoke(Result.success(Unit))
            return getMessageApdu()
        }

        return null
    }

    override fun onDeactivated(reason: Int) {
        message = null
        isConnected = false
        hasSent = false
        callback = null
    }

    private fun getMessageApdu(): ByteArray {
        // TODO cleaner Exception handling
        val messageBytes = StandardCharsets.UTF_8.encode(message ?: throw Exception())

        return messageBytes.array() + byteArrayOf(0x90.toByte(), 0x00)
    }
}
