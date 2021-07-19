import 'package:flutter/material.dart';
import 'package:service_rate_app/main.dart';
import 'package:service_rate_app/pages/qrRead.dart';
import 'package:service_rate_app/pages/serviceRate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config extends StatefulWidget {
  const Config({Key? key}) : super(key: key);

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  TextEditingController _urlController = TextEditingController();

  void handleSaveUrl() {}

  @override
  void initState() {
    super.initState();
    loadUrl();
  }

  void loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _urlController.text = prefs.getString('apiUrl') ?? '';
  }

  void saveUrl() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('apiUrl', _urlController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          alignment: Alignment.center,
          height: 28,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: appColors.red.withOpacity(0.6),
            ),
            child: Text(
              'Тохиргоо хадгалагдлаа.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ),
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              margin: EdgeInsets.fromLTRB(12, 50, 12, 10),
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 512),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: containerGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackToQrButton(),
                  Container(
                    margin: EdgeInsets.fromLTRB(4, 24, 0, 0),
                    child: Text(
                      'Серверийн тохиргоо:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: TextFormField(
                      controller: _urlController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.4),
                      ),
                      cursorColor: Colors.white,
                      cursorHeight: 20,
                      cursorRadius: Radius.circular(10),
                      autofocus: false,
                    ),
                  ),
                  Container(
                    height: 28,
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => saveUrl(),
                          child: Container(
                            child: Text(
                              'Хадгалах',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            side: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
