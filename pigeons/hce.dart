import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/pigeon/hce.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/com/example/flutter_nfc_p2p/Hce.g.kt',
    kotlinOptions: KotlinOptions(),
    swiftOut: 'ios/Runner/Hce.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'flutter_nfc_p2p',
  ),
)
@HostApi()
abstract class HceHostApi {
  @async
  void exposeMessage(String message);
}
