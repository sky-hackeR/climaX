import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  // Open-Meteo Forecast API URL
  final String forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast'; 

  // Geocoding API from OpenStreetMap Nominatim
  final String geocodeUrl = 'https://nominatim.openstreetmap.org/search'; 

  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final coordinates = await _getCoordinatesForCity(city);
    if (coordinates == null) {
      throw Exception('Could not find location for $city');
    }

    final url =
        '$forecastBaseUrl?latitude=${coordinates['lat']}&longitude=${coordinates['lon']}&current_weather=true';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather data');
    }
  }

  Future<Map<String, dynamic>> fetch7DayForecast(String city) async {
    final coordinates = await _getCoordinatesForCity(city);
    if (coordinates == null) {
      throw Exception('Could not find location for $city');
    }

    final url =
    '$forecastBaseUrl?latitude=${coordinates['lat']}&longitude=${coordinates['lon']}&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,windspeed_10m_max,precipitation_sum&timezone=auto';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load 7-day forecast data');
    }
  }

  Future<List<dynamic>?> fetchCitySuggestions(String query) async {
    final url =
        '$geocodeUrl?q=$query&format=json&limit=5&country=US'; // You can change country code or remove it

    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'FlutterWeatherApp'},
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  // Helper function to get latitude and longitude for a city
  Future<Map<String, double>?> _getCoordinatesForCity(String city) async {
    final url = '$geocodeUrl?q=$city&format=json&limit=1';

    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'FlutterWeatherApp'},
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        final firstResult = data[0];
        return {
          'lat': double.parse(firstResult['lat']),
          'lon': double.parse(firstResult['lon']),
        };
      }
    }
    return null;
  }

  // Fetch sunrise and sunset times using Open-Meteo Astronomy API
  Future<Map<String, dynamic>> fetchAstronomyData(double lat, double lon) async {
    final url =
        'https://api.open-meteo.com/v1/astronomy?latitude=$lat&longitude=$lon&current_weather=true&timezone=auto';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load astronomy data');
    }
  }
}