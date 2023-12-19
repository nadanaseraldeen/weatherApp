import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/NavBar.dart';

class DailyForecast extends StatefulWidget {
  const DailyForecast({Key? key}) : super(key: key);

  @override
  _DailyForecastState createState() => _DailyForecastState();
}

class _DailyForecastState extends State<DailyForecast> {
  static const String API_KEY = "5c12358112004c5985d142759231412";
  List<Map<String, dynamic>> dailyWeatherForecast = [];

  // API calling
  String dailyForecastAPI = "http://api.weatherapi.com/v1/forecast.json?key=" +
      API_KEY +
      "&days=7&q=";

  void fetchDailyForecast(String searchText) async {
    try {
      var forecastResult =
      await http.get(Uri.parse(dailyForecastAPI + searchText));
      final forecastData =
      Map<String, dynamic>.from(json.decode(forecastResult.body));

      setState(() {
        dailyWeatherForecast = (forecastData["forecast"]["forecastday"] as List)
            .cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Error :$e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherForStaticCity();
  }

  void _fetchWeatherForStaticCity() async {
    final prefs = await SharedPreferences.getInstance();
    String staticCity = prefs.getString('staticCity') ?? 'London'; // Default to 'London'
    fetchDailyForecast(staticCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavBar(), // Assuming NavBar is correctly set up
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('7 Day Daily Forecast', style: TextStyle(fontSize: 20)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/sc.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: dailyWeatherForecast.length,
          itemBuilder: (context, index) {
            return _buildDailyForecastCard(dailyWeatherForecast[index]);
          },
        ),
      ),
    );
  }

  Widget _buildDailyForecastCard(Map<String, dynamic> dayForecast) {
    String dateStr = dayForecast["date"];
    DateTime date = DateTime.parse(dateStr);
    String dayName = DateFormat('EEEE').format(date);  // Format to day name

    String weatherIconUrl =
    dayForecast["day"]["condition"]["icon"].replaceAll('//', 'https://');

    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(weatherIconUrl, height: 40, width: 40),
        title: Text(
          dayName, // Displaying the day name
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            'High: ${dayForecast["day"]["maxtemp_c"]}°C, Low: ${dayForecast["day"]["mintemp_c"]}°C',
            style: TextStyle(fontSize: 16)),
        onTap: () {},
      ),
    );
  }
}
