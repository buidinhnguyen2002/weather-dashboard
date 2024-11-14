import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_dashboard/models/weather_data.dart';
import 'package:weather_dashboard/providers/weather_forecast_provider.dart';
import 'package:weather_dashboard/utils/constants.dart';
import 'package:weather_dashboard/widgets/card_weather_forecast.dart';
import 'package:weather_dashboard/widgets/card_weather_to_day.dart';
import 'package:weather_dashboard/widgets/common_button.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _locationController = TextEditingController();
  bool weatherLoading = false;
  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  String _location = "Unknown location";
  Position? currentLocation;
  List<Placemark>? placemarks;
  Future<Position> _determinePosition() async {
    bool serviceEnable;
    LocationPermission permission;
    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      return Future.error("Location services are disable.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return Future.error("Location permissions are denied");
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }
    return await Geolocator.getCurrentPosition();
  }

  void _showFormRegisterDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String email = '';
    String city = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Register',
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Province/City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter province/city';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    city = value!;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  print('Email: $email');
                  print('City: $city');
                  String message = await Provider.of<WeatherForecastProvider>(
                          context,
                          listen: false)
                      .registerNotification(email, city);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void _showFormUnsubscribeDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String email = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Unsubscribe',
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Unsubscribe'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  print('Email: $email');
                  String message = await Provider.of<WeatherForecastProvider>(
                          context,
                          listen: false)
                      .unsubscribeNotification(email);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final weatherForecastProvider =
        Provider.of<WeatherForecastProvider>(context);
    final weathers = weatherForecastProvider.weatherForecast;
    final todayWeather = weatherForecastProvider.todayWeather;
    final weatherFuture = weatherForecastProvider.weatherFuture;
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                "Weather Dashboard",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  SizedBox(
                    width: (deviceSize.width - 50) * 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Enter a City Name"),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _locationController,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7.0),
                              borderSide: const BorderSide(
                                width: 2.0,
                              ),
                            ),
                            labelText: 'City',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7.0),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CommonButton(
                          text: "Search",
                          background: Theme.of(context).colorScheme.primary,
                          onPress: () async {
                            setState(() {
                              weatherLoading = true;
                            });
                            await Provider.of<WeatherForecastProvider>(context,
                                    listen: false)
                                .getWeatherForecast(_locationController.text);
                            setState(() {
                              weatherLoading = false;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              "or",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CommonButton(
                          text: "Use Current Location",
                          background: Theme.of(context).colorScheme.secondary,
                          onPress: () async {
                            currentLocation = await _determinePosition();
                            placemarks = await placemarkFromCoordinates(
                                currentLocation?.latitude ?? 37.4219,
                                currentLocation?.longitude ?? -122.084);
                            print(placemarks);
                          },
                        ),
                        BoxEmpty.sizeBox7,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () {
                                  _showFormRegisterDialog(context);
                                },
                                child: const Text("Register notification")),
                            TextButton(
                                onPressed: () {
                                  _showFormUnsubscribeDialog(context);
                                },
                                child: const Text("Unsubscribe notification")),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  if (weatherLoading)
                    const Expanded(
                        child: Center(child: CircularProgressIndicator()))
                  else
                    weathers.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                  "Please enter province/city to see weather forecast"),
                            ),
                          )
                        : Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CardWeatherToDay(
                                  location: todayWeather!.location,
                                  date: todayWeather.date,
                                  temperature: todayWeather.avgTempC,
                                  wind: todayWeather.maxWindKph,
                                  humidity: todayWeather.avgHumidity,
                                  icon: todayWeather.icon,
                                  textCondition: todayWeather.textCondition,
                                ),
                                BoxEmpty.sizeBox25,
                                const Text(
                                  "4-Day Forecast",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                BoxEmpty.sizeBox25,
                                Expanded(
                                  // height: 300,
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        children: [
                                          ...weatherFuture.map((weatherData) {
                                            return CardWeatherForecast(
                                              date: weatherData.date,
                                              temperature: weatherData.avgTempC,
                                              wind: weatherData.maxWindKph,
                                              humidity: weatherData.avgHumidity,
                                              icon: todayWeather.icon,
                                              textCondition:
                                                  todayWeather.textCondition,
                                            );
                                          }).toList(),
                                          Center(
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                await Provider.of<
                                                            WeatherForecastProvider>(
                                                        context,
                                                        listen: false)
                                                    .loadMoreWeatherForecast();
                                              },
                                              child: Text("Load more"),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
