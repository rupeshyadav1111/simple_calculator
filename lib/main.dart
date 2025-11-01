import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:app_settings_plus/app_settings_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MyApp());
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// 🏠 Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 3,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Calculator Section
              Column(
                children: [
                  const Icon(Icons.calculate_rounded,
                      size: 80, color: Colors.indigo),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CalculatorPage()),
                        );
                      },
                      icon: const Icon(Icons.functions_rounded),
                      label: const Text('Open Calculator'),
                    ),
                  ),
                ],
              ),

              // 🧭 Add space between sections
              const SizedBox(height: 60),

              // 🔹 Network Section
              Column(
                children: [
                  const Icon(Icons.wifi_tethering_rounded,
                      size: 80, color: Colors.deepOrangeAccent),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NoInternetPage()),
                        );
                      },
                      icon: const Icon(Icons.wifi_off_rounded),
                      label: const Text('No Internet Page'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// 🧮 Calculator Page
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = '';

  void onButtonClick(String value) {
    setState(() {
      if (value == 'C') {
        display = '';
      } else if (value == '=') {
        try {
          // ignore: deprecated_member_use
          Parser p = Parser();
          Expression exp = p
              .parse(display.replaceAll('X', '*').replaceAll('÷', '/'));
          ContextModel cm = ContextModel();
          double result = exp.evaluate(EvaluationType.REAL, cm);
          if (result == result.toInt()) {
            display = result.toInt().toString();
          } else {
            display = result.toString();
          }
        } catch (e) {
          display = 'Error';
        }
      } else {
        display += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Simple Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerRight,
              child: Text(
                display,
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const Divider(color: Colors.white),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('÷'),
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('X'),
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('-'),
                    buildButton('C'),
                    buildButton('0'),
                    buildButton('='),
                    buildButton('+'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text) {
    return ElevatedButton(
      onPressed: () => onButtonClick(text),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            // ignore: deprecated_member_use
            text == '=' ? Colors.orangeAccent : Colors.white.withOpacity(0.9),
        foregroundColor:
            text == '=' ? Colors.white : Colors.black87,
        shadowColor: Colors.black26,
        elevation: 4,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// 🌐 No Internet Page
class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isConnected = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(dynamic results) {
    bool connected = false;

    if (results is List<ConnectivityResult>) {
      connected = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
    } else if (results is ConnectivityResult) {
      connected = results == ConnectivityResult.mobile ||
          results == ConnectivityResult.wifi;
    }

    setState(() {
      _isConnected = connected;
      _checking = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _openWifiSettings() {
    AppSettingsPlus.openAppSettings(type: AppSettingsType.wifi);
  }

  void _openMobileDataSettings() {
    AppSettingsPlus.openAppSettings(type: AppSettingsType.dataRoaming);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: _isConnected ? Colors.green : Colors.redAccent,
      ),
      backgroundColor: _isConnected ? Colors.green[50] : Colors.red[50],
      body: Center(
        child: _checking
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isConnected ? Icons.wifi : Icons.signal_wifi_off,
                    color: _isConnected ? Colors.green : Colors.red,
                    size: 90,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isConnected
                        ? 'You are connected to the Internet!'
                        : 'No Internet Connection',
                    style: TextStyle(
                      fontSize: 20,
                      color: _isConnected ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!_isConnected) ...[
                    ElevatedButton.icon(
                      onPressed: _openWifiSettings,
                      icon: const Icon(Icons.wifi),
                      label: const Text('Go to Wi-Fi Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _openMobileDataSettings,
                      icon: const Icon(Icons.network_cell),
                      label: const Text('Turn On Mobile Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
