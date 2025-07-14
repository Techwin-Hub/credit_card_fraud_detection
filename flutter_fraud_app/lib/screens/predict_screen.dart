import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictScreen extends StatefulWidget {
  const PredictScreen({Key? key}) : super(key: key);

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};

  final List<String> fields = [
    'Time',
    ...List.generate(28, (i) => 'V${i + 1}'),
    'Amount'
  ];

  String? result;

  @override
  void initState() {
    super.initState();
    for (var field in fields) {
      controllers[field] = TextEditingController();
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, double> input = {
      for (var key in controllers.keys) key: double.parse(controllers[key]!.text)
    };

    final url = Uri.parse('http://127.0.0.1:5000/predict');
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input));

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      setState(() {
        result = jsonRes['fraud'] ? '⚠️ Fraud Detected' : '✅ Safe Transaction';
      });
    } else {
      setState(() {
        result = '❌ Error: ${res.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credit Card Fraud Detector"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                ...fields.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: controllers[f],
                    decoration: InputDecoration(
                      labelText: f,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                )),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submit,
                  child: const Text("Predict"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (result != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result!,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
