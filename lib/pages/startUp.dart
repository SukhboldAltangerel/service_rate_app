import 'package:flutter/material.dart';
import 'package:service_rate_app/main.dart';
import 'package:service_rate_app/routes/router.dart';

class StartUp extends StatefulWidget {
  const StartUp({Key? key}) : super(key: key);

  @override
  _StartUpState createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(
      seconds: 3,
    ),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _slide = Tween<Offset>(begin: Offset(0.0, -1.5), end: Offset(0.0, -1))
        .animate(_animation);

    _controller
        .forward()
        .whenComplete(() => Navigator.pushNamed(context, qrReadRoute));
  }

  void handleTap() {
    Navigator.pushNamed(context, qrReadRoute);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => handleTap(),
      child: Container(
        color: appColors.background,
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: _slide,
            child: Image(
              image: AssetImage('lib/assets/logo.png'),
              color: appColors.pink,
              width: 240,
            ),
          ),
        ),
      ),
    );
  }
}
