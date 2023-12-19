import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherForecastProvider with ChangeNotifier {
  static const String API_KEY = "5c12358112004c5985d142759231412";
  List<Map<String, dynamic>> _hourlyWeatherForecast = [];
  List<Map<String, dynamic>> _dailyWeatherForecast = [];

  List<Map<String, dynamic>> get hourlyWeatherForecast => _hourlyWeatherForecast;
  List<Map<String, dynamic>> get dailyWeatherForecast => _dailyWeatherForecast;

  Future<void> fetchWeatherForecast(String searchText) async {
    try {
      var forecastResult = await http.get(Uri.parse("http://api.weatherapi.com/v1/forecast.json?key=$API_KEY&days=3&hours=24&q=$searchText"));
      final forecastData = json.decode(forecastResult.body);

      if (forecastData.containsKey("error")) {
        print("API Error: ${forecastData["error"]["message"]}");
        return;
      }

      _hourlyWeatherForecast = (forecastData["forecast"]["forecastday"][0]["hour"] as List).cast<Map<String, dynamic>>();
      _dailyWeatherForecast = (forecastData["forecast"]["forecastday"] as List).cast<Map<String, dynamic>>();

      notifyListeners();
    } catch (e) {
      print("Error: $e");
    }
  }
}
