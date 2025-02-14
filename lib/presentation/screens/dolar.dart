import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/dolar_repository.dart';

class DolarScreen extends StatefulWidget {
  const DolarScreen({super.key});

  @override
  _DolarScreenState createState() => _DolarScreenState();
}

class _DolarScreenState extends State<DolarScreen> {
  final TextEditingController _anoController = TextEditingController();
  final DolarRepository _dolarRepository = DolarRepository();

  List<double> cotacoes = [];
  List<int> meses = [];

  Future<void> buscarCotacaoDolar() async {
    String ano = _anoController.text.trim();
    if (ano.isEmpty) return;

    try {
      List<Map<String, dynamic>> dados = await _dolarRepository.fetchDolarData(ano);
      processarDados(dados);
    } catch (e) {
      print('Erro ao buscar dados: $e');
    }
  }

  void processarDados(List<Map<String, dynamic>> dados) {
    List<List<Map<String, dynamic>>> mesesFiltrados = List.generate(12, (_) => []);

    for (var item in dados) {
      int mesIndex = int.parse(item['dataHoraCotacao'].substring(5, 7)) - 1;
      mesesFiltrados[mesIndex].add(item);
    }

    for (var mes in mesesFiltrados) {
      mes.sort((a, b) => (a['cotacaoVenda'] as double).compareTo(b['cotacaoVenda']));
    }

    setState(() {
      cotacoes = mesesFiltrados
          .where((mes) => mes.isNotEmpty)
          .map((mes) => mes.last['cotacaoVenda'] as double)
          .toList();

      meses = mesesFiltrados
          .where((mes) => mes.isNotEmpty)
          .map((mes) => int.parse(mes.last['dataHoraCotacao'].substring(5, 7)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotação do Dólar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informe o ano que deseja consultar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _anoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ano (ex: 2023)',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: buscarCotacaoDolar,
                  child: const Text('Consultar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Center(child: Text('Variação durante o ano')),
            Expanded(
              child: cotacoes.isEmpty
                  ? const Center(child: Text('Nenhuma informação disponível'))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  return Text(
                                    meses.isNotEmpty &&
                                            index >= 0 &&
                                            index < meses.length
                                        ? meses[index].toString()
                                        : '',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                cotacoes.length,
                                (index) => FlSpot(
                                    meses[index].toDouble(), cotacoes[index]),
                              ),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.green,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Fonte: Banco Central do Brasil',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
