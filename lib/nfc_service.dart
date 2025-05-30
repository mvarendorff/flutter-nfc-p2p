import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import 'pigeon/hce.g.dart';

class NfcService {
  static final _hce = HceHostApi();

  static Future<String> exchangeMessage(String message, bool sendFirst) async {
    if (sendFirst) await sendMessage(message);
    final result = await receiveMessage();
    if (!sendFirst) await sendMessage(message);

    return result;
  }

  static Future<void> sendMessage(String message) async {
    await _hce.exposeMessage(message);
  }

  static Future<String> receiveMessage() async {
    final tag = await FlutterNfcKit.poll();
    if (tag.type != NFCTagType.iso7816) {
      await FlutterNfcKit.finish();
      throw Exception('Wrong tag type ${tag.type} found!');
    }

    await _selectP2pAid();
    final responseBytes = await FlutterNfcKit.transceive(
        Uint8List.fromList([0, 0, 0, 0, 0x01, 0, 0xFF]));

    final result = responseBytes.reversed.take(2).toList().reversed.toList();
    if (result[0] == 0x90 && result[1] == 0x00) print('Result matched!');

    final mutableResponseBytes = List.of(responseBytes);
    mutableResponseBytes.length -= 2;
    await FlutterNfcKit.finish();

    final responseString = utf8.decode(mutableResponseBytes);
    print('Received response $responseString');

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

    print('Sending SELECT AID');
    final responseBytes = (await FlutterNfcKit.transceive(apdu));
    print('Received SELECT AID response:');
    print(responseBytes
        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
        .join(' '));
  }
}
