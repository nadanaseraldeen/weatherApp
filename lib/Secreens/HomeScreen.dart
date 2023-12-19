import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Import shared_preferences

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String API_KEY = "5c12358112004c5985d142759231412";
  bool isLoading = false;
  String errorMessage = '';

  String location = 'London';  // Default location
  String weatherIcon = '';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  String searchWeatherAPI = "http://api.weatherapi.com/v1/current.json?key=" + API_KEY + "&q=";

  @override
  void initState() {
    super.initState();
    _loadStaticCity();
  }

  void _loadStaticCity() async {
    final prefs = await SharedPreferences.getInstance();
    String staticCity = prefs.getString('staticCity') ?? 'London'; // Default to 'London' if not set
    fetchWeatherData(staticCity);
  }

  void fetchWeatherData(String searchText) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      var searchResult = await http.get(Uri.parse(searchWeatherAPI + searchText));
      if (searchResult.statusCode == 200) {
        final weatherData = json.decode(searchResult.body);

        setState(() {
          location = weatherData["location"]["name"];
          var parsedDate = DateTime.parse(weatherData["location"]["localtime"].substring(0, 10));
          currentDate = DateFormat('MMMMEEEEd').format(parsedDate);

          weatherIcon = weatherData["current"]["condition"]["icon"].replaceAll('//', 'https://');
          temperature = weatherData["current"]["temp_c"].toInt();
          windSpeed = weatherData["current"]["wind_kph"].toInt();
          humidity = weatherData["current"]["humidity"].toInt();
          cloud = weatherData["current"]["cloud"].toInt();
        });
        isLoading = false;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('The Weather In Your City', style: TextStyle(fontSize: 20)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/sc.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              height: 400,
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isLoading) CircularProgressIndicator(),
                  if (errorMessage.isNotEmpty) Text(errorMessage, style: TextStyle(color: Colors.red)),
                  if (!isLoading && errorMessage.isEmpty) Column(
                    children: [
                      Text(
                        location,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      weatherIcon.isNotEmpty
                          ? Image.network(weatherIcon, height: 80, width: 80)
                          : SizedBox.shrink(),
                      SizedBox(height: 8),
                      Text('$temperature°C', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Windspeed: $windSpeed km/h', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Humidity: $humidity%', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Cloud: $cloud%', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 8),
                      Text(currentDate, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
