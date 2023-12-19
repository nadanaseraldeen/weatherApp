import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../NavBar.dart';
import '../database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CityWeatherData {
  final String cityName;
  int temperature;
  String description;
  String iconUrl;

  CityWeatherData({
    required this.cityName,
    this.temperature = 0,
    this.description = '',
    this.iconUrl = '',
  });
}

class CityWeather extends StatefulWidget {
  const CityWeather({Key? key}) : super(key: key);

  @override
  State<CityWeather> createState() => _CityWeatherState();
}

class _CityWeatherState extends State<CityWeather> {
  List<CityWeatherData> cityWeatherDataList = [];
  static const String API_KEY = "5c12358112004c5985d142759231412";
  final String weatherAPI = "http://api.weatherapi.com/v1/current.json?key=$API_KEY&q=";
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoredCities();
  }

  void _loadStoredCities() async {
    var storedCities = await DatabaseHelper.instance.getCities();
    cityWeatherDataList = storedCities.map((cityName) => CityWeatherData(cityName: cityName)).toList();
    for (var cityData in cityWeatherDataList) {
      fetchWeatherData(cityData);
    }
  }

  void fetchWeatherData(CityWeatherData cityData) async {
    try {
      var weatherResult = await http.get(Uri.parse(weatherAPI + cityData.cityName));
      if (weatherResult.statusCode == 200) {
        final weatherData = json.decode(weatherResult.body);
        setState(() {
          cityData.temperature = weatherData['current']['temp_c'].toInt();
          cityData.description = weatherData['current']['condition']['text'];
          cityData.iconUrl = "http:${weatherData['current']['condition']['icon']}";
        });
      } else {
        throw Exception('City not found.');
      }
    } catch (e) {
      print("Error fetching weather data for ${cityData.cityName}: $e");
    }
  }

  void _addCityToDatabase(String cityName) async {
    await DatabaseHelper.instance.addCity(cityName);
    _loadStoredCities();
  }

  void _searchCity() async {
    if (_cityController.text.isNotEmpty) {
      try {
        var response = await http.get(Uri.parse(weatherAPI + _cityController.text));
        if (response.statusCode == 200) {
          _addCityToDatabase(_cityController.text);
          fetchWeatherData(CityWeatherData(cityName: _cityController.text));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("City Not Found"),
                content: Text("The city entered could not be found. Please try again."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print("Error: $e");
      } finally {
        _cityController.clear();
      }
    }
  }

  void _setStaticCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staticCity', cityName);
  }

  void _deleteCity(String cityName) async {
    await DatabaseHelper.instance.deleteCity(cityName);
    _loadStoredCities();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('City Weather Information', style: TextStyle(fontSize: 20)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/sc.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter City Name',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchCity,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cityWeatherDataList.length,
                itemBuilder: (context, index) {
                  var cityData = cityWeatherDataList[index];
                  return ListTile(
                    title: Text(cityData.cityName),
                    subtitle: Text('Temperature: ${cityData.temperature}°C, ${cityData.description}'),
                    leading: cityData.iconUrl.isNotEmpty ? Image.network(cityData.iconUrl) : null,
                    trailing: Wrap(
                      spacing: 12, // space between two icons
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.star),
                          onPressed: () => _setStaticCity(cityData.cityName),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCity(cityData.cityName),
                        ),
                      ],
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
