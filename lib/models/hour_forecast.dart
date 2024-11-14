class HourForecast {
  final int id;
  final String time;
  final double tempC;
  final double tempF;
  final double windKph;
  final double precipMm;
  final int humidity;
  final int chanceOfRain;
  final String textCondition;
  final String icon;

  HourForecast({
    required this.id,
    required this.time,
    required this.tempC,
    required this.tempF,
    required this.windKph,
    required this.precipMm,
    required this.humidity,
    required this.chanceOfRain,
    required this.textCondition,
    required this.icon,
  });

  factory HourForecast.fromJson(Map<String, dynamic> json) {
    return HourForecast(
      id: json['id'],
      time: json['time'],
      tempC: json['temp_c'].toDouble(),
      tempF: json['temp_f'].toDouble(),
      windKph: json['windKph'].toDouble(),
      precipMm: json['precipMm'].toDouble(),
      humidity: json['humidity'],
      chanceOfRain: json['chanceOfRain'],
      textCondition: json['textCondition'],
      icon: json['icon'],
    );
  }
}
