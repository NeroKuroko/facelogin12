import 'dart:io';

import 'package:face_login/pages/widgets/app_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final String username;
  final String imagePath;

  const Profile(this.username, {super.key, required this.imagePath});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  BluetoothConnection? connection;
  bool isConnected = false;
  bool isLedOn = false;
  bool isServoOpen = false;

  @override
  void initState() {
    super.initState();
    _connectToBluetooth();
  }

  Future<void> _connectToBluetooth() async {
    try {
      connection = await BluetoothConnection.toAddress(
          '98D367F56AD0'); 
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error al conectar: $e');
      }
    }
  }

  void _sendMessage(String message) async {
    if (isConnected && connection != null) {
      connection!.output.add(Uint8List.fromList(message.codeUnits));
      await connection!.output.allSent;
    }
  }

  void _toggleLed() {
    setState(() {
      isLedOn = !isLedOn;
      _sendMessage(isLedOn ? 'L' : 'l');
    });
  }

  void _toggleServo() {
    setState(() {
      isServoOpen = !isServoOpen;
      _sendMessage(isServoOpen ? 'S' : 's');
    });
  }

  @override
  void dispose() {
    connection?.dispose();
    connection = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard de ${widget.username}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(widget.imagePath)),
                            ),
                          ),
                          margin: const EdgeInsets.all(20),
                          width: 100,
                          height: 100,
                        ),
                        Text(
                          'Hola ${widget.username}!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEFFC1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.thermostat_outlined,
                                size: 30,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'BEDROOM',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 200,
                    color: Colors.grey.shade200,
                    child: Column(
                      children: [
                        _buildControlSwitch('LIGHTS', Icons.lightbulb_outline,
                            _toggleLed, isLedOn),
                        _buildControlSwitch('DOORS', Icons.door_front_door,
                            _toggleServo, isServoOpen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade300,
              padding: const EdgeInsets.all(10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.bed, size: 30),
                  Icon(Icons.shower, size: 30),
                  Icon(Icons.kitchen, size: 30),
                  Icon(Icons.chair, size: 30),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: "Salir",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              color: const Color(0xFFFF6161),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSwitch(
      String title, IconData icon, VoidCallback onChanged, bool value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Switch(
            value: value,
            onChanged: (bool newValue) {
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
