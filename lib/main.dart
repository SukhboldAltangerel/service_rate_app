import 'package:flutter/material.dart';
import 'package:service_rate_app/routes/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Үйлчилгээнд үнэлгээ өгөх',
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: startUpRoute,
    );
  }
}

class AppColors {
  var background = Colors.white;
  var pink = Color.fromRGBO(240, 119, 179, 1);
  var orange = Color.fromRGBO(238, 131, 81, 1);
  var red = Color.fromRGBO(239, 76, 126, 1);
  var middle = Color.fromRGBO(239, 105, 102, 1);
  var lightPink = Color.fromRGBO(255, 236, 247, 1);
}

AppColors appColors = new AppColors();

String Authorization =
    'Basic aW5mb3N5c3RlbXNsbGM6SW5mb3N5c3RlbXNQcm90ZWN0ZWRQYXNzd29yZDcwMTJA';
