import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyCalcApp());
}

/// ENTRY POINT & THEME
class MyCalcApp extends StatelessWidget {
  const MyCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold, color: Colors.cyanAccent),
          bodyMedium: TextStyle(fontFamily: 'RobotoMono', fontSize: 16),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class ElectronicsMath {
  static Map<String, double> calculateRC(double i, double v, double r, double f) {
    if (i == 0) throw Exception("Current (I) cannot be zero.");
    if (f == 0) throw Exception("Frequency (F) cannot be zero.");

    double z = v / i;
    // Fixed: Replaced math.pow with direct multiplication
    double radicand = (z * z) - (r * r);

    if (radicand < 0) throw Exception("V/I (Z) must be ≥ R.");

    double xc = math.sqrt(radicand);
    if (xc == 0) throw Exception("Calculated XC is zero.");

    // Fixed: Used scientific notation instead of math.pow
    double c = 1e6 / (2 * math.pi * f * xc);
    double vr = i * r;
    double vc = i * xc;
    double p1 = vr * i;
    double p2 = vc * i;
    double p3 = v * i;
    double pf = v != 0 ? (vr / v) : 0;
    double pa = vr != 0 ? (math.atan(vc / vr) * 180 / math.pi) : 90.0;

    return {
      "XC": xc,
      "XC_pico": xc * 1e12,
      "Z": z,
      "I": i,
      "VR": vr,
      "VC": vc,
      "P1": p1,
      "P2": p2,
      "P3": p3,
      "PF": pf,
      "PA": pa,
      "C": c,
    };
  }

  static Map<String, double> calculateLC(double i, double v, double f) {
    if (i == 0) throw Exception("Current (I) cannot be zero.");
    if (f == 0) throw Exception("Frequency (F) cannot be zero.");

    double xl = v / i;
    if (xl == 0) throw Exception("Invalid XL value.");

    double l = xl / (2 * math.pi * f);
    double c = xl / (2 * math.pi * f * 1e-6);

    return {
      "XL": xl,
      "C": c,
      "L": l,
    };
  }
}
class LCDDisplay extends StatelessWidget {
  final String text;
  const LCDDisplay({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        // Fixed: Updated to .withValues(alpha: ...)
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.5), width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          // Fixed: Updated to .withValues(alpha: ...)
          BoxShadow(color: Colors.cyan.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'RobotoMono', fontSize: 16, height: 1.5),
      ),
    );
  }
}
class ElectronicInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const ElectronicInput({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.cyanAccent)),
        ),
      ),
    );
  }
}

/// HOME SCREEN
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MyCalc Analyzer', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("SELECT CIRCUIT MODULE", style: TextStyle(color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), backgroundColor: const Color(0xFF1E1E1E), foregroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.cyan, width: 1), borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RCScreen())),
              child: const Text("R-C Series Circuit"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), backgroundColor: const Color(0xFF1E1E1E), foregroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.cyan, width: 1), borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LCScreen())),
              child: const Text("Inductance / AC Circuit"),
            ),
          ],
        ),
      ),
    );
  }
}

/// R-C SCREEN
class RCScreen extends StatefulWidget {
  const RCScreen({super.key});
  @override
  State<RCScreen> createState() => _RCScreenState();
}

class _RCScreenState extends State<RCScreen> {
  final _iCtrl = TextEditingController();
  final _vCtrl = TextEditingController();
  final _rCtrl = TextEditingController();
  final _fCtrl = TextEditingController();
  String _result = "AWAITING INPUT...";

  void _calculate() {
    try {
      double i = double.parse(_iCtrl.text);
      double v = double.parse(_vCtrl.text);
      double r = double.parse(_rCtrl.text);
      double f = double.parse(_fCtrl.text);

      final res = ElectronicsMath.calculateRC(i, v, r, f);
      setState(() {
        _result = "XC = ${res['XC']!.toStringAsFixed(6)} Ω\n"
            "XC(p) = ${res['XC_pico']!.toStringAsFixed(6)}\n"
            "Z = ${res['Z']!.toStringAsFixed(6)} Ω\n"
            "I = ${res['I']!.toStringAsFixed(6)} A\n"
            "VR = ${res['VR']!.toStringAsFixed(6)} V\n"
            "VC = ${res['VC']!.toStringAsFixed(6)} V\n"
            "P(True) = ${res['P1']!.toStringAsFixed(6)} W\n"
            "P(React) = ${res['P2']!.toStringAsFixed(6)} W\n"
            "P(App) = ${res['P3']!.toStringAsFixed(6)} W\n"
            "PF = ${res['PF']!.toStringAsFixed(6)}\n"
            "Phase = ${res['PA']!.toStringAsFixed(6)}°\n"
            "C = ${res['C']!.toStringAsFixed(6)} µF";
      });
    } catch (e) {
      setState(() => _result = "ERR: ${e.toString().replaceAll('Exception: ', '')}");
    }
  }

  void _clear() {
    _iCtrl.clear();
    _vCtrl.clear();
    _rCtrl.clear();
    _fCtrl.clear();
    setState(() => _result = "AWAITING INPUT...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROG 170: SERIES R-C')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElectronicInput(label: "Current (I) Amperes", controller: _iCtrl),
            ElectronicInput(label: "Voltage (V) Volts", controller: _vCtrl),
            ElectronicInput(label: "Resistance (R) Ohms", controller: _rCtrl),
            ElectronicInput(label: "Frequency (F) Hz", controller: _fCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _calculate, style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[900], foregroundColor: Colors.white), child: const Text("COMPUTE"))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton(onPressed: _clear, style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], foregroundColor: Colors.white), child: const Text("CLEAR"))),
              ],
            ),
            const SizedBox(height: 24),
            LCDDisplay(text: _result),
          ],
        ),
      ),
    );
  }
}

/// L-C SCREEN
class LCScreen extends StatefulWidget {
  const LCScreen({super.key});
  @override
  State<LCScreen> createState() => _LCScreenState();
}

class _LCScreenState extends State<LCScreen> {
  final _iCtrl = TextEditingController();
  final _vCtrl = TextEditingController();
  final _fCtrl = TextEditingController();
  String _result = "AWAITING INPUT...";

  void _calculate() {
    try {
      double i = double.parse(_iCtrl.text);
      double v = double.parse(_vCtrl.text);
      double f = double.parse(_fCtrl.text);

      final res = ElectronicsMath.calculateLC(i, v, f);
      setState(() {
        _result = "XL = ${res['XL']!.toStringAsFixed(6)} Ω\n"
            "C = ${res['C']!.toStringAsFixed(6)} µF\n"
            "L = ${res['L']!.toStringAsFixed(6)} H";
      });
    } catch (e) {
      setState(() => _result = "ERR: ${e.toString().replaceAll('Exception: ', '')}");
    }
  }

  void _clear() {
    _iCtrl.clear();
    _vCtrl.clear();
    _fCtrl.clear();
    setState(() => _result = "AWAITING INPUT...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('INDUCTANCE / AC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElectronicInput(label: "Current (I) Amperes", controller: _iCtrl),
            ElectronicInput(label: "Voltage (V) Volts", controller: _vCtrl),
            ElectronicInput(label: "Frequency (F) Hz", controller: _fCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _calculate, style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[900], foregroundColor: Colors.white), child: const Text("COMPUTE"))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton(onPressed: _clear, style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], foregroundColor: Colors.white), child: const Text("CLEAR"))),
              ],
            ),
            const SizedBox(height: 24),
            LCDDisplay(text: _result),
          ],
        ),
      ),
    );
  }
}