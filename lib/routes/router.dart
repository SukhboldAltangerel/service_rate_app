import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:service_rate_app/pages/config.dart';
import 'package:service_rate_app/pages/qrRead.dart';
import 'package:service_rate_app/pages/serviceRate.dart';
import 'package:service_rate_app/pages/startUp.dart';

const startUpRoute = '/';
const qrReadRoute = '/qr-read';
const configRoute = '/config';
const serviceRateRoute = '/service-rate';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // print('👀 ${settings.name}');
    late Widget page;

    switch (settings.name) {
      case startUpRoute:
        page = StartUp();
        break;
      case qrReadRoute:
        page = QrRead();
        break;
      case configRoute:
        page = Config();
        break;
      case serviceRateRoute:
        var args = settings.arguments as ServiceRateArguments;
        page = ServiceRate(
          barcode: args.barcode,
        );
        break;
      default:
        page = NotFound(url: settings.name);
    }

    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );

    // return PageRouteBuilder(
    //   pageBuilder: (context, animation, secondaryAnimation) => page,
    //   transitionDuration: Duration(milliseconds: 1000),
    //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //     var tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
    //     var curvedAnimation = CurvedAnimation(
    //       parent: animation,
    //       curve: Curves.easeInOut,
    //     );

    //     return SlideTransition(
    //       position: tween.animate(curvedAnimation),
    //       child: child,
    //     );
    //   },
    // );
  }
}

class NotFound extends StatelessWidget {
  const NotFound({Key? key, @required this.url}) : super(key: key);
  final url;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Text('$url not found 404.'),
      ),
    );
  }
}

class ServiceRateArguments {
  final Barcode barcode;

  ServiceRateArguments(this.barcode);
}
