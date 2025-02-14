import 'package:http/http.dart' as http;
import 'dart:convert';

class DolarRepository {
  Future<List<Map<String, dynamic>>> fetchDolarData(String ano) async {
    String url =
        'https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/'
        'CotacaoDolarPeriodo(dataInicial=@dataInicial,dataFinalCotacao=@dataFinalCotacao)?'
        '@dataInicial=%2701-01-$ano%27&@dataFinalCotacao=%2712-31-$ano%27&\$format=json';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> dados = jsonDecode(response.body)['value'];
        return List<Map<String, dynamic>>.from(dados);
      } else {
        throw Exception('Erro ao buscar dados da API');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}
