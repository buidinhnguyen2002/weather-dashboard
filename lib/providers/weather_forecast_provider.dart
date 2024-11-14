import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather_dashboard/models/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:weather_dashboard/utils/constants.dart';

class WeatherForecastProvider with ChangeNotifier {
  List<WeatherData> _weatherForecast = [];
  WeatherData? _todayWeather;
  List<WeatherData> _weatherFuture = [];
  List<WeatherData> get weatherForecast {
    return _weatherForecast;
  }

  WeatherData? get todayWeather {
    return _todayWeather;
  }

  List<WeatherData> get weatherFuture {
    return _weatherFuture;
  }

  Future<void> getWeatherForecast(String location) async {
    try {
      final response = await http
          .get(Uri.parse('${API.forecast}?location=$location'), headers: {
        'Content-Type': 'application/json',
      });
      print(response.statusCode);
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedResponse);

      if (response.statusCode == 200) {
        _weatherForecast =
            data.map((weather) => WeatherData.fromJson(weather)).toList();
        _splitWeatherDataByDate();
      } else {
        throw Exception("ERROR");
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> loadMoreWeatherForecast() async {
    final String date = _weatherForecast.last.date;
    final String location = _weatherForecast.last.location;
    try {
      final response = await http.get(
          Uri.parse('${API.moreForecast}?location=$location&date=$date'),
          headers: {
            'Content-Type': 'application/json',
          });
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(decodedResponse);

      if (response.statusCode == 200) {
        List<WeatherData> weathers =
            data.map((weather) => WeatherData.fromJson(weather)).toList();
        _weatherFuture = [..._weatherFuture, ...weathers];
        _weatherForecast = [..._weatherForecast, ...weathers];
      } else {
        throw Exception("ERROR");
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  void _splitWeatherDataByDate() {
    DateTime today = DateTime.now();
    _todayWeather = _weatherForecast.firstWhere(
      (weather) => _isSameDay(weather.date, today),
      orElse: () => _weatherForecast.first,
    );
    _weatherFuture = _weatherForecast
        .where((weather) => !_isSameDay(weather.date, today))
        .toList();
  }

  bool _isSameDay(String dateStr, DateTime date) {
    DateTime weatherDate = DateTime.parse(dateStr);
    return weatherDate.year == date.year &&
        weatherDate.month == date.month &&
        weatherDate.day == date.day;
  }

  Future<String> registerNotification(String email, String location) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${API.registerNotification}?email=$email&location=$location'),
      );
      final decodedResponse = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedResponse);
      if (response.statusCode == 200) {
        return data["message"];
      } else {
        return "An error occurred.";
      }
    } catch (error) {
      throw error;
    }
  }

  Future<String> unsubscribeNotification(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${API.unsubscribeNotification}?email=$email'),
      );
      final decodedResponse = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedResponse);
      if (response.statusCode == 200) {
        return data["message"];
      } else {
        return "An error occurred.";
      }
    } catch (error) {
      throw error;
    }
  }
}
