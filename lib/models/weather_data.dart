import 'package:weather_dashboard/models/hour_forecast.dart';

class WeatherData {
  final int id;
  final String location;
  final String date;
  final double maxTempC;
  final double minTempC;
  final double avgTempC;
  final double maxTempF;
  final double minTempF;
  final double avgTempF;
  final double maxWindKph;
  final double totalPrecipMm;
  final int avgHumidity;
  final int dailyChanceOfRain;
  final String textCondition;
  final String icon;
  final List<HourForecast> hourForecasts;

  WeatherData({
    required this.id,
    required this.location,
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.avgTempC,
    required this.maxTempF,
    required this.minTempF,
    required this.avgTempF,
    required this.maxWindKph,
    required this.totalPrecipMm,
    required this.avgHumidity,
    required this.dailyChanceOfRain,
    required this.textCondition,
    required this.icon,
    required this.hourForecasts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    var list = json['hourForecasts'] as List;
    List<HourForecast> hourForecastList =
        list.map((i) => HourForecast.fromJson(i)).toList();

    return WeatherData(
      id: json['id'],
      location: json['location'],
      date: json['date'],
      maxTempC: json['maxTempC'].toDouble(),
      minTempC: json['minTempC'].toDouble(),
      avgTempC: json['avgTempC'].toDouble(),
      maxTempF: json['maxTempF'].toDouble(),
      minTempF: json['minTempF'].toDouble(),
      avgTempF: json['avgTempF'].toDouble(),
      maxWindKph: json['maxWindKph'].toDouble(),
      totalPrecipMm: json['totalPrecipMm'].toDouble(),
      avgHumidity: json['avgHumidity'],
      dailyChanceOfRain: json['dailyChanceOfRain'],
      textCondition: json['textCondition'],
      icon: json['icon'],
      hourForecasts: hourForecastList,
    );
  }
}
