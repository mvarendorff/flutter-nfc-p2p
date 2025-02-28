import 'dart:async';
import 'dart:convert';

import 'package:nearby_cross/constants/nearby_strategies.dart';
import 'package:nearby_cross/models/advertiser_model.dart';
import 'package:nearby_cross/models/discoverer_model.dart';
import 'package:nearby_cross/models/message_model.dart';

class NearbyService {
  static Future<String> exchangeAsAdvertiser(String payload) async {
    final completer = Completer<String>();
    final advertiser = Advertiser();
    await advertiser.requestPermissions();

    advertiser.connectionsManager.setCallbackConnectionInitiated('yeet',
        (device) async {
      await advertiser.connectionsManager.acceptConnection(device.endpointId);
    });

    advertiser.connectionsManager.setCallbackSuccessfulConnection('success',
        (device) async {
      await advertiser.stopAdvertising();
      device.sendMessage(NearbyMessage.fromString(payload));
    });

    advertiser.connectionsManager.setCallbackReceivedMessage('yoink',
        (device) async {
      final message = device.getLastMessage()?.message;
      await advertiser.stopAllConnections();

      if (message != null) {
        completer.complete(utf8.decode(message));
      }
    });

    await advertiser.advertise(
      'p2p-testing',
      strategy: NearbyStrategies.pointToPoint,
    );

    return await completer.future;
  }

  static Future<String> exchangeAsDiscoverer(String payload) async {
    final completer = Completer<String>();
    final discoverer = Discoverer();

    await discoverer.requestPermissions();

    discoverer.connectionsManager.setCallbackConnectionInitiated('yeet',
        (device) async {
      await discoverer.connectionsManager.acceptConnection(device.endpointId);
    });

    discoverer.connectionsManager.setCallbackReceivedMessage('yoink',
        (device) async {
      print('Received a new message on connectionsManager');
      device.sendMessage(NearbyMessage.fromString(payload));

      final message = device.getLastMessage()?.message;
      await discoverer.stopAllConnections();

      if (message != null) {
        completer.complete(utf8.decode(message));
      } else {
        completer.completeError(
          'Did not receive a last message something bad so very bad :((',
        );
      }
    });

    discoverer.callbackOnDeviceFound = (device) async {
      await discoverer.stopDiscovering();
      await discoverer.connect(device.endpointId);
    };

    await discoverer.startDiscovery(
      'p2p-testing',
      strategy: NearbyStrategies.pointToPoint,
    );

    return await completer.future;
  }
}
