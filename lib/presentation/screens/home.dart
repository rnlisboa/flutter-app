import 'package:flutter/material.dart';
import 'package:trabalhoddm/presentation/screens/clima.dart';
import 'package:trabalhoddm/presentation/screens/dolar.dart';
import 'package:trabalhoddm/presentation/widgets/button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seja bem-vindo.'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Cotação Dólar',
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DolarScreen()),
                );
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
