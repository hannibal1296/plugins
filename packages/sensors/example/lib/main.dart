// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sensors/sensors.dart';

import 'snake.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  // @override
  // _MyHomePageState createState() => _MyHomePageState();
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  Location location = Location();
  double elevation = 0.0;
  bool counted = false;

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    // 물음표는 NullException 방지. 만약, 대상이 null이면 오류 없이 null을 리턴.
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // main column
        children: <Widget>[
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
              child: SizedBox(
                height: _snakeRows * _snakeCellSize,
                width: _snakeColumns * _snakeCellSize,
                child: Snake(
                  rows: _snakeRows,
                  columns: _snakeColumns,
                  cellSize: _snakeCellSize,
                ),
              ),
            ),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void getAltitude(BuildContext context) async {
    LocationData _locationData = await location.getLocation();
    if (_locationData.altitude != elevation) {
      elevation = _locationData.altitude;
      developer.log('Elevation: $elevation', name: "Altitude");
    }
  }

  // AccelerometerEvent, GyroscopeEvent, and UserAccelerometerEvent are
  // pre-defined in the 'sensor' package.
  @override
  void initState() {
    super.initState();

    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });

      double xAccThreshold = 10.0;
      if (!counted && (event.x > xAccThreshold || event.x < -xAccThreshold)) {
        getAltitude(context);
        counted = true;
        scaffoldKey.currentState
            .showSnackBar(const SnackBar(content: Text('Accelerated')));
        developer.log(<double>[event.x, event.y, event.z].join('.'),
            name: "AccelerometerEvent");
      } else if (counted && event.x < 0.1 && event.x > -0.1) {
        counted = false;
        developer.log('SnackBar has been reset.', name: 'Reset log.');
      }
    }));

    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));

    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
  }
}
