import 'dart:ui';

import 'package:climax/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  String _city = 'Abuja';

  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecastData;
  

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final current = await _weatherService.fetchCurrentWeather(_city);
      final forecast = await _weatherService.fetch7DayForecast(_city);

      setState(() {
        _currentWeather = current;
        _forecastData = forecast;
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  IconData getWeatherIcon(int weatherCode) {
    if (weatherCode == 0 || weatherCode == 1) return Icons.sunny;
    if (weatherCode >= 2 && weatherCode <= 3) return Icons.cloud;
    if (weatherCode >= 45 && weatherCode <= 48) return Icons.foggy;
    if (weatherCode >= 51 && weatherCode <= 67) return Icons.water_drop;
    if (weatherCode >= 71 && weatherCode <= 77) return Icons.ac_unit;
    if (weatherCode >= 80 && weatherCode <= 82) return Icons.thunderstorm;
    if (weatherCode >= 95 && weatherCode <= 99) return Icons.flash_on;
    return Icons.help_outline;
  }

  String getWeatherDescription(int weatherCode) {
    if (weatherCode == 0) return "Clear sky";
    if (weatherCode == 1) return "Mainly clear";
    if (weatherCode == 2) return "Partly cloudy";
    if (weatherCode == 3) return "Overcast";
    if (weatherCode >= 45 && weatherCode <= 48) return "Fog";
    if (weatherCode >= 51 && weatherCode <= 67) return "Rain";
    if (weatherCode >= 71 && weatherCode <= 77) return "Snow fall";
    if (weatherCode >= 80 && weatherCode <= 82) return "Showers";
    if (weatherCode >= 95 && weatherCode <= 99) return "Thunderstorm";
    return "Unknown";
  }

  String getSunriseTime() {
    if (_forecastData != null &&
        _forecastData!.containsKey('daily') &&
        _forecastData!['daily'].containsKey('sunrise') &&
        _forecastData!['daily']['sunrise'].isNotEmpty) {
      return _forecastData!['daily']['sunrise'][0].split('T')[1].split('+')[0];
    }
    return '—';
  }

  String getSunsetTime() {
    if (_forecastData != null &&
        _forecastData!.containsKey('daily') &&
        _forecastData!['daily'].containsKey('sunset') &&
        _forecastData!['daily']['sunset'].isNotEmpty) {
      return _forecastData!['daily']['sunset'][0].split('T')[1].split('+')[0];
    }
    return '—';
  }

  String getWindSpeed() {
    if (_currentWeather != null &&
        _currentWeather!.containsKey('current_weather') &&
        _currentWeather!['current_weather'].containsKey('windspeed')) {
      return '${_currentWeather!['current_weather']['windspeed']} m/s';
    }
    return '—';
  }

  String getPrecipitation() {
    if (_forecastData != null &&
        _forecastData!.containsKey('daily') &&
        _forecastData!['daily'].containsKey('precipitation_sum') &&
        _forecastData!['daily']['precipitation_sum'].isNotEmpty) {
      final precipitation = _forecastData!['daily']['precipitation_sum'][0];
      if (precipitation > 0) {
        return '$precipitation mm';
      } else {
        return 'None';
      }
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentWeather == null
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueGrey],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueGrey],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    _city,
                    style: GoogleFonts.lato(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          getWeatherIcon(
                              _currentWeather!['current_weather']['weathercode']),
                          size: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_currentWeather!['current_weather']['temperature']} °C',
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          getWeatherDescription(
                              _currentWeather!['current_weather']['weathercode']),
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_forecastData != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Max: ${_forecastData!['daily']['temperature_2m_max'][0].toStringAsFixed(1)}°C',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Min: ${_forecastData!['daily']['temperature_2m_min'][0].toStringAsFixed(1)}°C',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            "Loading forecast...",
                            style: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 45),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeatherDetail("Sunrise", Icons.wb_sunny_outlined, getSunriseTime()),
                      _buildWeatherDetail("Sunset", Icons.nightlight_round, getSunsetTime()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeatherDetail("Wind", Icons.air, getWindSpeed()),
                      _buildWeatherDetail("Precipitation", Icons.water_drop, getPrecipitation()),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWeatherDetail(String label, IconData icon, String value) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 100,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}