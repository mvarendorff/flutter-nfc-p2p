import 'dart:math';

import 'package:flutter/material.dart';

import 'nearby_service.dart';
import 'utils.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: NfcPlayground(),
    );
  }
}

class NfcPlayground extends StatefulWidget {
  const NfcPlayground({super.key});

  @override
  State<NfcPlayground> createState() => _NfcPlaygroundState();
}

class _NfcPlaygroundState extends State<NfcPlayground> {
  final _random = Random();

  String _mine = '';
  String _theirs = '';
  String _mode = '';

  Future<void> _doNearbyExchangeA() async {
    setState(() {
      _mine = _random.nextString(5);
      _theirs = '';
      _mode = 'A';
    });

    final receivedTheirs = await NearbyService.exchangeAsAdvertiser(_mine);
    setState(() => _theirs = receivedTheirs);
  }

  Future<void> _doNearbyExchangeD() async {
    setState(() {
      _mine = _random.nextString(5);
      _theirs = '';
      _mode = 'D';
    });

    final receivedTheirs = await NearbyService.exchangeAsDiscoverer(_mine);
    setState(() => _theirs = receivedTheirs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Mine: $_mine'),
            Text('Theirs: $_theirs'),
            Text('Mode: $_mode'),
            OutlinedButton(
              onPressed: _doNearbyExchangeA,
              child: const Text('Do Nearby Exchange (A)'),
            ),
            OutlinedButton(
              onPressed: _doNearbyExchangeD,
              child: const Text('Do Nearby Exchange (D)'),
            ),
          ],
        ),
      ),
    );
  }
}
