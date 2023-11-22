import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista para armazenar as posições coletadas
  List<Position> _positionList = [];
  // Timer para chamar periodicamente a função _getCurrentLocation
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Inicializa o timer ao criar o widget
    _timer = Timer.periodic(
        Duration(minutes: 1), (Timer t) => _getCurrentLocation());
  }

  @override
  void dispose() {
    // Cancela o timer ao destruir o widget
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localização do Dispositivo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Exibe a lista de coordenadas
            if (_positionList.isNotEmpty)
              Column(
                children: _positionList
                    .map((position) => Text(
                          'Latitude: ${position.latitude}\nLongitude: ${position.longitude}',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ))
                    .toList(),
              ),
            SizedBox(height: 20),
            // Botão para obter a localização atual
            ElevatedButton(
              onPressed: () {
                _getLocationPermission();
              },
              child: Text('Obter Localização Atual'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para obter a localização atual do dispositivo
  _getCurrentLocation() async {
    try {
      // Obtém a posição atual com alta precisão
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Adiciona a nova posição à lista
      setState(() {
        _positionList.add(position);
      });
    } catch (e) {
      // Trata qualquer erro que ocorra durante a obtenção da localização
      print(e);
    }
  }

  // Método para solicitar permissão de localização
  _getLocationPermission() async {
    // Solicita a permissão de localização
    var status = await Permission.location.request();

    if (status.isGranted) {
      // Se a permissão for concedida, obtém a localização atual
      _getCurrentLocation();
    } else {
      // Permissão negada. Trate conforme necessário.
      print('Permissão de localização negada');
    }
  }
}
