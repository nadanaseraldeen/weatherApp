import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../WeatherForecastProvider.dart';

class HourlyForecast extends StatefulWidget {
  const HourlyForecast({Key? key}) : super(key: key);

  @override
  _HourlyForecastState createState() => _HourlyForecastState();
}

class _HourlyForecastState extends State<HourlyForecast> {
  @override
  void initState() {
    super.initState();
    _fetchWeatherForStaticCity();
  }

  void _fetchWeatherForStaticCity() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the static city or use a default one
    String staticCity = prefs.getString('staticCity') ?? 'London';
    Provider.of<WeatherForecastProvider>(context, listen: false).fetchWeatherForecast(staticCity);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeatherForecastProvider>(context);
    List<Map<String, dynamic>> hourlyForecastData = provider.hourlyWeatherForecast;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Hourly Forecast',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/sc.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: hourlyForecastData.length,
          itemBuilder: (context, index) {
            return _buildHourlyForecastCard(hourlyForecastData[index]);
          },
        ),
      ),
    );
  }

  Widget _buildHourlyForecastCard(Map<String, dynamic> hourForecast) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          '${hourForecast["time"]}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Temperature: ${hourForecast["temp_c"]}°C',
          style: TextStyle(fontSize: 16),
        ),
        leading: Image.network(
          'https:${hourForecast["condition"]["icon"]}',
          height: 40,
          width: 40,
        ),
      ),
    );
  }
}
