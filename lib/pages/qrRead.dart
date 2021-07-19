import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:service_rate_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:service_rate_app/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrRead extends StatefulWidget {
  const QrRead({Key? key}) : super(key: key);

  @override
  _QrReadState createState() => _QrReadState();
}

class _QrReadState extends State<QrRead> with SingleTickerProviderStateMixin {
  final GlobalKey _qrKey = GlobalKey();
  late Barcode _barcode;
  late QRViewController _controller;
  bool _cameraOn = false;
  Data? _data;
  bool _expanded = false;
  late String apiUrl;

  late final AnimationController _animController = AnimationController(
    duration: Duration(milliseconds: 600),
    vsync: this,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    loadUrl().then((_) => fetchData().whenComplete(() => setState(() {})));
  }

  Future<void> loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      apiUrl = prefs.getString('apiUrl') ?? '';
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller.pauseCamera();
    } else if (Platform.isIOS) {
      _controller.resumeCamera();
    }
  }

  void handleToggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
    _expanded ? _animController.forward() : _animController.reverse();
  }

  void handleCameraToggle() {
    setState(() {
      _cameraOn = !_cameraOn;
    });
  }

  Future<void> fetchData() async {
    final res = await http.get(
      Uri.parse('$apiUrl/rates/info'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: Authorization,
      },
    );
    setState(() {
      _data = Data.fromJson(jsonDecode(res.body));
    });
  }

  void onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    bool scanned = false;
    _controller.scannedDataStream.listen((scanData) {
      setState(() {
        _barcode = scanData;
      });
      if (!scanned) {
        scanned = true;
        Navigator.popAndPushNamed(
          context,
          serviceRateRoute,
          arguments: ServiceRateArguments(_barcode),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Material(
      child: Container(
        color: appColors.background,
        child: Stack(
          children: [
            Container(
              height: screenHeight,
              width: screenWidth,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => handleToggleExpanded(),
                    child: Container(
                      width: screenWidth - 24,
                      constraints: BoxConstraints(
                        maxWidth: 512,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: containerGradient,
                      ),
                      margin: EdgeInsets.only(top: 50),
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Өнөөдөр',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  'Үнэлгээ өгсөн үйлчлүүлэгчдийн тоо:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Text(
                                  '${_data?.ratecount ?? ''}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizeTransition(
                            sizeFactor: _animation,
                            axis: Axis.vertical,
                            axisAlignment: -1,
                            child: StarReview(
                              rates: _data?.rates,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => handleCameraToggle(),
                        child: Container(
                          width: min(screenWidth - 60, 360),
                          height: min(screenWidth - 60, 360),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: appColors.pink.withOpacity(0.6),
                              width: _cameraOn ? 0 : 1,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              var width = constraints.maxWidth * 0.8;
                              return _cameraOn
                                  ? QRView(
                                      key: _qrKey,
                                      onQRViewCreated: onQRViewCreated,
                                      overlay: QrScannerOverlayShape(
                                        cutOutSize: width,
                                        borderWidth: 10,
                                        borderLength: 20,
                                        borderRadius: 10,
                                        borderColor: appColors.pink,
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 48,
                                        color: appColors.pink,
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 22,
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                crossFadeState: _cameraOn
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  width: screenWidth,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20),
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
                      'Тооцооны баримтын QR кодыг уншуулна уу.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                secondChild: Container(
                  width: screenWidth,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.popAndPushNamed(context, configRoute),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Тохиргоо',
                          style: TextStyle(
                            color: appColors.pink,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 1),
                          child: Icon(
                            Icons.settings_outlined,
                            color: appColors.pink,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<BoxShadow> containerShadow = [
  BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: 2,
    color: Colors.black.withOpacity(0.1),
  ),
];

LinearGradient containerGradient = LinearGradient(
  colors: [
    appColors.red.withOpacity(0.8),
    appColors.orange.withOpacity(0.8),
  ],
);

class StarReview extends StatelessWidget {
  const StarReview({
    Key? key,
    @required this.rates,
  }) : super(key: key);

  final List<Rates>? rates;

  int? getRatingCount(rating) {
    if (rates == null) return 0;
    Rates rate = rates!.firstWhere(
      (rate) => rate.rating == rating,
      orElse: () => Rates(
        rating: rating,
        count: 0,
      ),
    );
    return rate.count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
          child: Text(
            'Үйлчилгээнүүдэд өгсөн үнэлгээ:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ),
        ...List<int>.generate(5, (i) => 5 - i)
            .map((rating) => Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List<int>.generate(rating, (i) => i + 1)
                            .map((e) => Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 3),
                                  child: Icon(
                                    Icons.star,
                                    size: 24,
                                    color: Colors.yellow,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        '${getRatingCount(rating)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ))
            .toList(),
      ],
    );
  }
}

class Data {
  bool? success;
  int? ratecount;
  List<Rates>? rates;

  Data({
    this.success,
    this.ratecount,
    this.rates,
  });

  Data.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    ratecount = json['ratecount'];
    if (json['rates'] != null) {
      rates = <Rates>[];
      json['rates'].forEach((v) {
        rates?.add(new Rates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['ratecount'] = this.ratecount;
    if (this.rates != null) {
      data['rates'] = this.rates?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rates {
  int? rating;
  int? count;

  Rates({
    this.rating,
    this.count,
  });

  Rates.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['count'] = this.count;
    return data;
  }
}
