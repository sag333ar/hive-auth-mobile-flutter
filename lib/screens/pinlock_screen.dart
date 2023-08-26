import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({
    Key? key,
    required this.data,
  });

  final HiveAuthSignerData data;

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HiveAuth Signer'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hello World!',
            ),
          ],
        ),
      ),
    );
  }
}
