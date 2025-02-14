import 'package:flutter/material.dart';
import 'package:trabalhoddm/presentation/screens/clima.dart';
import 'package:trabalhoddm/presentation/screens/dolar.dart';
import 'package:trabalhoddm/presentation/widgets/button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seja bem-vindo.'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Digite seu nome',
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Cotação Dólar',
              color: Colors.green,
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DolarScreen(name: _nameController.text),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Clima',
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClimaScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
