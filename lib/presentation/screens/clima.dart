import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../service/database_service.dart';
import '../../data/models/cidade_model.dart';

class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  _ClimaScreenState createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  String cidade = "Brasília";
  double temperatura = 0;
  String condicao = "";
  List<Map<String, dynamic>> previsao = [];
  final DatabaseService dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _carregarCidade();
  }

  Future<void> _carregarCidade() async {
    Cidade? cidadeSalva = await dbService.recuperarCidade();
    if (cidadeSalva != null) {
      setState(() {
        cidade = cidadeSalva.nome;
      });
    }
    buscarClima(cidade);
  }

  Future<void> buscarClima(String cidade) async {
    try {
      final geoUrl = Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$cidade&format=json");
      final geoResponse = await http.get(geoUrl);
      final geoData = json.decode(geoResponse.body);

      if (geoData.isEmpty) {
        throw Exception("Cidade não encontrada");
      }

      double latitude = double.parse(geoData[0]["lat"]);
      double longitude = double.parse(geoData[0]["lon"]);

      final climaUrl = Uri.parse(
          "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=America/Sao_Paulo");

      final climaResponse = await http.get(climaUrl);
      final climaData = json.decode(climaResponse.body);

      setState(() {
        temperatura = climaData["current_weather"]["temperature"];
        condicao = interpretarCondicao(climaData["current_weather"]["weathercode"]);
        previsao = List.generate(3, (index) {
          return {
            "dia": ["Hoje", "Amanhã", "Depois de Amanhã"][index],
            "max": climaData["daily"]["temperature_2m_max"][index],
            "min": climaData["daily"]["temperature_2m_min"][index],
            "codigo": climaData["daily"]["weathercode"][index]
          };
        });
      });

      // Salvar cidade pesquisada no banco
      await dbService.salvarCidade(Cidade(id: 1, nome: cidade));

    } catch (e) {
      setState(() {
        condicao = "Erro ao carregar clima";
      });
    }
  }

  String interpretarCondicao(int codigo) {
    if (codigo == 0) return "Ensolarado";
    if (codigo <= 3) return "Parcialmente Nublado";
    if (codigo <= 48) return "Névoa";
    if (codigo <= 57) return "Chuvisco";
    if (codigo <= 99) return "Chuva";
    return "Desconhecido";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Clima'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Digite uma cidade",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                setState(() {
                  cidade = value;
                });
                buscarClima(value);
              },
            ),
            const SizedBox(height: 20),
            Text(
              cidade,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "$temperatura°C",
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            Text(
              condicao,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: previsao.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(previsao[index]["dia"]),
                      subtitle: Text(
                          "Máx: ${previsao[index]["max"]}°C, Mín: ${previsao[index]["min"]}°C"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
