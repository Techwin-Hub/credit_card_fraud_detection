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
      appBar: AppBar(title: const Text("Credit Card Fraud Detector")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...fields.map((f) => TextFormField(
                controller: controllers[f],
                decoration: InputDecoration(labelText: f),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              )),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: submit, child: const Text("Predict")),
              const SizedBox(height: 20),
              if (result != null)
                Text(result!, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
