import 'package:flutter/material.dart';
import 'package:/screens/splash.dart';
import 'routes/route_generator.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: GenerateAllRoutes.generateRoute,
      home: Splash(),
    );
  }
}
