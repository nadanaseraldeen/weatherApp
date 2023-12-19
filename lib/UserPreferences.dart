import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class UserPreferences with ChangeNotifier {
  List<String> _favoriteCities = [];

  List<String> get favoriteCities => _favoriteCities;

  // Load favorite cities from database on initialization
  UserPreferences() {
    loadFavoriteCities();
  }

  // Function to load favorite cities from the database
  void loadFavoriteCities() async {
    _favoriteCities = await DatabaseHelper.instance.getCities();
    notifyListeners();
  }

  // Function to add a city to favorites and database
  void addCity(String city) async {
    if (!_favoriteCities.contains(city)) {
      _favoriteCities.add(city);
      await DatabaseHelper.instance.addCity(city);
      notifyListeners();
    }
  }

  // Function to remove a city from favorites and database
  void removeCity(String city) async {
    _favoriteCities.remove(city);
    // Add functionality to remove city from the database if required
    // Example: await DatabaseHelper.instance.removeCity(city);
    notifyListeners();
  }
}
