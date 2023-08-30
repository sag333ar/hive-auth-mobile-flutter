import 'package:flutter/material.dart';
import 'package:hiveauthsigner/data/hiveauthdata.dart';
import 'package:hiveauthsigner/data/hiveauthsignerdata.dart';
import 'package:hiveauthsigner/screens/dashboard.dart';
import 'package:hiveauthsigner/screens/drawer_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({
    super.key,
    required this.data,
  });

  final HiveAuthSignerData data;

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  bool? canWeDoBioScan;
  var pinText = '';
  var rePinText = '';

  @override
  void initState() {
    super.initState();
    loadBioStatus();
  }

  void loadBioStatus() async {
    var result = await hiveAuthData.pinStorageManager.hasBiometrics();
    setState(() {
      canWeDoBioScan = result;
    });
  }

  Widget _loading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text(
            'Loading',
          ),
        ],
      ),
    );
  }

  Widget _noBio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Please enable TouchID / FaceID to use the Hive Signer App',
          ),
        ],
      ),
    );
  }

  Widget _inputPin() {
    return TextField(
      decoration: const InputDecoration(
        icon: Icon(Icons.pin),
        label: Text('App Pin'),
        hintText: 'Enter 6-Digit App Unlock Pin here',
      ),
      obscureText: true,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          pinText = value;
        });
      },
    );
  }

  Widget _reInputPin() {
    return TextField(
      decoration: const InputDecoration(
        icon: Icon(Icons.pin),
        label: Text('ReEnter App Pin'),
        hintText: 'RE-Enter 6-Digit App Unlock Pin here',
      ),
      obscureText: true,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          rePinText = value;
        });
      },
    );
  }

  void navigateToDashboard() {
    var screen = DashboardScreen(data: widget.data);
    var route = MaterialPageRoute(builder: (c) => screen);
    Navigator.of(context).pushReplacement(route);
  }

  Widget _submitButton() {
    var enteredPin = pinText.trim();
    var shouldEnable = enteredPin.length == 6;
    if (shouldEnable) {
      var checkText = enteredPin.replaceAll(RegExp(r"[0-9]"), "");
      if (checkText.isNotEmpty) {
        shouldEnable = false;
      }
    }
    if (widget.data.doWeHaveSecurePin == false) {
      var reEnteredPin = rePinText.trim();
      if (shouldEnable) {
        shouldEnable = reEnteredPin == enteredPin;
      }
    }
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.red[800]),
      ),
      onPressed: shouldEnable
          ? () async {
              if (widget.data.doWeHaveSecurePin == false) {
                await hiveAuthData.pinStorageManager.setSecurePin(enteredPin);
                hiveAuthData.setPin(true, widget.data);
                hiveAuthData.setLockUnlockApp(true, widget.data);
                hiveAuthData.setMp(enteredPin, widget.data);
                setState(() {
                  navigateToDashboard();
                });
              } else {
                var result = await hiveAuthData.pinStorageManager
                    .validatePin(enteredPin);
                if (result) {
                  hiveAuthData.setLockUnlockApp(true, widget.data);
                  hiveAuthData.setMp(enteredPin, widget.data);
                  showMessage('Auth Signer App unlocked.');
                  setState(() {
                    navigateToDashboard();
                  });
                } else {
                  showError('Incorrect PIN entered.');
                }
              }
            }
          : null,
      child: Text(
        widget.data.doWeHaveSecurePin == false ? 'Set App Pin' : 'Unlock',
      ),
    );
  }

  Widget _noPinSet() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          children: [
            _inputPin(),
            const SizedBox(height: 15),
            _reInputPin(),
            const SizedBox(height: 15),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _pinSet() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          children: [
            _inputPin(),
            const SizedBox(height: 15),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _withBio() {
    if (widget.data.doWeHaveSecurePin == false) {
      return _noPinSet();
    } else {
      return _pinSet();
    }
  }

  void showError(String string) async {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) async {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: ListTile(
          leading: Image.asset(
            'assets/app-icon.png',
            width: 40,
            height: 40,
          ),
          title: const Text('Auth Signer'),
          subtitle: const Text('Pin Unlock'),
        ),
      ),
      body: canWeDoBioScan == null
          ? _loading()
          : canWeDoBioScan == false
              ? _noBio()
              : _withBio(),
      // drawer: DrawerScreen(data: widget.data),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     hiveAuthData.startSocket(widget.data.hasWsServer);
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}
