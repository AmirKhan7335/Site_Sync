import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/centralBarScreens/const.dart';

class PageThree extends StatefulWidget {
  const PageThree({super.key});

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  String? location = 'Unknown';
  String? weatherDescription = 'Unknown';
  double temperature = 0;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('engineers')
            .doc(currentUser.email)
            .get();
        String? projectId = userSnapshot['projectId'];
        if (projectId != null) {
          DocumentSnapshot projectSnapshot = await FirebaseFirestore.instance
              .collection('Projects')
              .doc(projectId)
              .get();
          location = projectSnapshot['location'];
          if (location != null) {
            List<Location> locations = await locationFromAddress(location!);
            if (locations.isNotEmpty) {
              Location cityLocation = locations.first;
              Weather weather = await _wf.currentWeatherByLocation(
                  cityLocation.latitude, cityLocation.longitude);
              setState(() {
                weatherDescription = weather.weatherDescription ?? 'Unknown';
                temperature = weather.temperature?.celsius ?? 0;
              });
            } else {
              setState(() {
                location = 'City not found';
              });
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weather data: $e');
      }
      setState(() {
        location = 'Failed';
        weatherDescription = 'Failed';
      });
    }
  }

  IconData getWeatherIcon(String weatherDescription) {
    switch (weatherDescription.toLowerCase()) {
      case 'clouds':
        return Icons.cloud;
      case 'clear':
        return Icons.wb_sunny;
      case 'rain':
        return Icons.grain;
    // Add more cases as needed for other weather conditions
      default:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Flexible(
              child: Text(
                'Weather at $location:',
                style: const TextStyle(fontSize: 20, color: Colors.black),
                maxLines: 3, // Adjust maxLines as needed
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Icon(
                      getWeatherIcon(weatherDescription ?? ''),
                      size: 100,
                      color: Colors.yellow,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(2, 2),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: weatherDescription ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 60),
              Transform.translate(
                offset: const Offset(2, 7),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${temperature.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 50,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(
                        text: '\nCurrent Weather',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
