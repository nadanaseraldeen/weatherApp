import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Secreens/welcome.dart';
import 'WeatherForecastProvider.dart';
import 'UserPreferences.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => WeatherForecastProvider()),
      ChangeNotifierProvider(create: (context) => UserPreferences()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather app',
      home: WelcomeScreen(),
      // other properties ...
    );
  }
}
