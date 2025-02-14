import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ClimaRepository {
  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização permanentemente negada.');
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Map<String, dynamic>>> fetchWeatherData() async {
    try {
      Position position = await getLocation();
      double latitude = position.latitude;
      double longitude = position.longitude;

      String url =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<String> timeList = List<String>.from(data['hourly']['time']);
        List<double> tempList = List<double>.from(data['hourly']['temperature_2m']);

        List<Map<String, dynamic>> weatherData = List.generate(timeList.length, (index) {
          return {
            'hour': int.parse(timeList[index].substring(11, 13)), // Pega a hora
            'temperature': tempList[index]
          };
        });

        return weatherData;
      } else {
        throw Exception('Erro ao buscar dados do clima.');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}
