import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: unused_import
import 'weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  bool isEmpty = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    // Call your API here
    fetchDataFromApi();
  }

  Future<void> fetchDataFromApi() async {
    setState(() {
      isLoading = true;
      isEmpty = false;
      isError = false;
    });
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&current_weather=true&timezone=auto'));

    if (response.statusCode == 200) {
      users = json.decode(response.body)['results'];
      isEmpty = users.isEmpty;
      setState(() {
        isLoading = false;
        isError = false;
      });
    } else {
      setState(() {
        isLoading = false;
        isError = true;
        isEmpty = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Weather App'),
            backgroundColor: const Color.fromARGB(255, 135, 169, 224),
            titleTextStyle: const TextStyle(color: Colors.black),
            actions: const [Icon(Icons.menu)],
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/weather.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: const WeatherScreen(),
          ),
        ));
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);
  
  dynamic get isDay => isDay;
  
  dynamic get temperature => temperature;
  
  dynamic get windspeed => windspeed;

  @override
 
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  List<WeatherScreen> weatherData = [];

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: latitudeController,
            decoration: const InputDecoration(
              labelText: 'Latitude',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Color.fromARGB(179, 206, 235, 78)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
          ),
          TextField(
            controller: longitudeController,
            decoration: const InputDecoration(
              labelText: 'Longitude',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Color.fromARGB(179, 206, 235, 78)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 50, 220, 121)),
              ),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {
              const double latitude = 52.52;
              const double longitude = 13.41;
              fetchWeatherData(latitude, longitude);
            },
            child: const Text('Get Weather'),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: ListView.builder(
              itemCount: weatherData.length,
              itemBuilder: (context, index) {
                final weather = weatherData[
                    index]; 
                return ListTile(
                  title: Text('isDay: ${weather.isDay}'),
                  subtitle: Text('Temperature: ${weather.temperature}°C'),
                  trailing: Text('Windspeed: ${weather.windspeed}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Weather>> fetchWeatherData(
      double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&current_weather=true&timezone=auto'));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

       
        final dailyForecasts = decodedData['daily']['time_series'];

       
        final List<Weather> fetchedWeatherData = [];

       
        for (final forecast in dailyForecasts) {
          final date = forecast['isday'];
          final maxTemp = forecast['temperature_2m_max'];
          final minTemp = forecast['temperature_2m_min'];
          final description = forecast['windspeed'];

         
          final weather = Weather(
            isDay: date,
            temperature: (maxTemp + minTemp) / 2.0,
            windspeed: description,
          );

          fetchedWeatherData.add(weather);
        }

        return fetchedWeatherData; 
      } else {
        print('API request error: ${response.statusCode}');
        return []; 
      }
    } catch (e) {
      print('Error: $e');
      return []; 
    }
  }
}

class Weather {
  final String isDay;
  final double temperature;
  final String windspeed;

  Weather({
    required this.isDay,
    required this.temperature,
    required this.windspeed,
  });
  String get getDate => isDay;
  double get getTemperature => temperature;
  String get getwindspeed => windspeed;
}



