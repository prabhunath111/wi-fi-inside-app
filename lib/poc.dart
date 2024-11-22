import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Poc extends StatefulWidget {
  const Poc({super.key});

  @override
  State<Poc> createState() => _PocState();
}

class _PocState extends State<Poc> {
  List<WifiNetwork> _wifiNetworks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Future<void> _connectToWifi(String ssid, String password) async {
    if(!await WiFiForIoTPlugin.isEnabled()) {
      await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
    }

    bool connected = await WiFiForIoTPlugin.connect(ssid, password: password,
      withInternet: false,
      security: NetworkSecurity.WPA,
    );
    if (connected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepPurpleAccent,
          content: Text('Connected to $ssid', style: const TextStyle(
        color: Colors.white
      ),)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepPurpleAccent,
          content: Text('Failed to connect to $ssid',
          style: const TextStyle(
              color: Colors.white
          ))));
    }
  }
  Future<void> _scanWifiNetworks() async {
    List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _wifiNetworks = networks;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nearby list updated: ')));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _wifiNetworks.isEmpty?
            const Center(child: Text("No network found.."),):ListView.builder(
            itemCount: _wifiNetworks.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i){
              final WifiNetwork data = _wifiNetworks[i];
          return Card(
            child: InkWell(
              onTap: () {
                _showPasswordDialog(data.ssid??"", context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.ssid??"--", style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 20.0
                    ),),
                    Text(data.bssid??"--"),
                    Text(data.capabilities??"--"),
                  ],
                ),
              ),
            ),
          );
        }),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            _scanWifiNetworks();
          },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
            ),
          child: const Text(
            "Get Network List",
              style: TextStyle(
            color: Colors.white
          ))
        ),
      ),
    );
  }
  void _showPasswordDialog(String ssid, BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Password for $ssid'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String password = passwordController.text;
                await _connectToWifi(ssid, password);
                Navigator.pop(context);
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }
}


