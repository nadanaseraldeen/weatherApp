import 'package:flutter/material.dart';
import 'Secreens/CityWeather.dart';
import 'Secreens/DailyForecast.dart';
import 'Secreens/HomeScreen.dart';
import 'Secreens/HourlyForecast.dart';

class NavBar extends StatelessWidget {
  final List<String>?cityNames;
  final Function(String)? onCityAdded;  // Optional: Callback function when a city is added

  const NavBar({Key? key, this.cityNames, this.onCityAdded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Weather Application", style: TextStyle(fontSize: 20)),
            accountEmail: null,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          ListTile(
            title: Text('Home Screen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Hourly Forecast'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HourlyForecast()),
              );
            },
          ),
          ListTile(
            title: Text('Daily Forecast'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DailyForecast()),
              );
            },
          ),
          ListTile(
            title: Text('Places'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CityWeather(),
              ),);
            },
          ),
        ],
      ),
    );
  }
}
