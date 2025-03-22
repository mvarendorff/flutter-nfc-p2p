package com.example.flutter_nfc_p2p

import java.nio.charset.StandardCharsets

class HceState {
    companion object {
        var message: String? = null
        var isConnected: Boolean = false
        var hasSent: Boolean = false
        var callback: ((Result<Unit>) -> Unit)? = null

        fun getMessageApdu(): ByteArray {
            // TODO cleaner Exception handling
            val messageBytes = StandardCharsets.UTF_8.encode(message ?: throw Exception())

            return messageBytes.array() + byteArrayOf(0x90.toByte(), 0x00)
        }
    }
}
