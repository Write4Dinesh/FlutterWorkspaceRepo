import 'package:flutfire/mlkit/acc_businesscard_scan.dart';

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'mlkit/acc_home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      new FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HelloFireML',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      // home: new WallScreen(analytics: analytics, observer: observer),
      home: new AccHome(),

    );
  }
}
