import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '027250573766a1cc6a05f38b8cc22ad9'; 
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    final url = Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
