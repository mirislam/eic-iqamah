import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math';

class CompassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
        backgroundColor: Color.fromARGB(255, 25, 114, 0),
      ),
      body: Center(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error reading compass data: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            double? direction = snapshot.data?.heading;

            // If direction is null, show a message
            if (direction == null) {
              return const Text(
                  "Device does not have sensors to show compass.");
            }

            return Container(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass Dial
                  Image.asset(
                    'assets/images/compass_dial1.png', // Add a compass dial image to your assets
                    height: 300,
                    width: 300,
                  ),
                  // Compass Needle
                  Transform.rotate(
                    angle: (direction * (pi / 180) * -1),
                    child: Image.asset(
                      'assets/images/compass_needle1.png', // Add a compass needle image to your assets
                      height: 150,
                      width: 150,
                    ),
                  ),
                  // Degree Text
                  Positioned(
                    bottom: 20,
                    child: Text(
                      '${direction.toStringAsFixed(2)}°',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
