import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import 'pigeon/hce.g.dart';

class NfcService {
  static final _hce = HceHostApi();
  static final StreamController<String> messages = StreamController.broadcast();

  static Future<String> exchangeMessage(String message, bool sendFirst) async {
    if (sendFirst) await sendMessage(message);
    final result = await receiveMessage();
    if (!sendFirst) await sendMessage(message);

    return result;
  }

  static Future<void> sendMessage(String message) async {
    messages.add('Sending message $message by calling _hce.exposeMessage');
    await _hce.exposeMessage(message);
  }

  static Future<String> receiveMessage() async {
    messages.add('Polling for nfc tag');
    final tag = await FlutterNfcKit.poll();
    messages.add('Tag found!');

    if (tag.type != NFCTagType.iso7816) {
      await FlutterNfcKit.finish();
      messages.add('Found tag type ${tag.type} which is invalid');
      throw Exception('Wrong tag type ${tag.type} found!');
    }

    await _selectP2pAid();

    messages.add('Sending dummy payload to trigger response');
    final responseBytes = await FlutterNfcKit.transceive(
      Uint8List.fromList([0, 0, 0, 0, 0x01, 0, 0xFF]),
    );
    final result = responseBytes.reversed.take(2).toList().reversed.toList();
    if (result[0] == 0x90 && result[1] == 0x00) messages.add('Positive result');

    final mutableResponseBytes = List.of(responseBytes);
    mutableResponseBytes.length -= 2;
    await FlutterNfcKit.finish();

    final responseString = utf8.decode(mutableResponseBytes);
    messages.add('Received response $responseString');

    return responseString;
  }

  static Future<void> _selectP2pAid() async {
    const selectAidCommand = [0x00, 0xA4, 0x04, 0x00];
    const aid = [0xF0, 0x93, 0x36, 0x70, 0x93, 0x36];
    final apdu = Uint8List(selectAidCommand.length + 1 + aid.length + 1);
    apdu.setAll(0, selectAidCommand);
    apdu[selectAidCommand.length] = aid.length;
    apdu.setAll(selectAidCommand.length + 1, aid);
    apdu[apdu.length - 1] = 0x00;

    messages.add(
      'Sending SELECT AID 0x${apdu.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
    );
    final responseBytes = (await FlutterNfcKit.transceive(apdu));
    messages.add('Received SELECT AID response:');
    messages.add(
      responseBytes
          .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
          .join(' '),
    );
  }
}
