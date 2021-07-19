import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:service_rate_app/main.dart';
import 'package:service_rate_app/pages/qrRead.dart';
import 'package:service_rate_app/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceRate extends StatefulWidget {
  const ServiceRate({Key? key, @required this.barcode}) : super(key: key);

  final Barcode? barcode;

  @override
  _ServiceRateState createState() => _ServiceRateState();
}

class _ServiceRateState extends State<ServiceRate> {
  Data? _data;
  String? _status;
  late String apiUrl;

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

  void handleRate(id, rating) {
    if (_status == 'success') return;

    setState(() {
      // var newServices = [...?data.services];
      var index = _data?.items?.indexWhere((service) => service.id == id);
      if (index != -1) {
        if (_data?.items?[index!].rating == rating) {
          _data?.items?[index!].rating = null;
        } else {
          _data?.items?[index!].rating = rating;
        }
      }
    });
  }

  Future<void> handleSubmit() async {
    setState(() {
      _status = 'loading';
    });

    final res = await http.post(
      Uri.parse('$apiUrl/order/rate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: Authorization,
      },
      body: jsonEncode(_data),
    );

    if (res.statusCode == 200) {
      setState(() {
        _status = 'success';
      });
    } else {
      setState(() {
        _status = 'error';
      });
    }
    showMaterialDialog();
  }

  Future<void> fetchData() async {
    final res = await http.get(
      Uri.parse('$apiUrl/order/info?id=${widget.barcode?.code}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: Authorization,
      },
    );
    setState(() {
      _data = Data.fromJson(jsonDecode(res.body));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Flex(
        direction: Axis.vertical,
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
                  margin: EdgeInsets.only(top: 24),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Гүйлгээний дугаар: ',
                        ),
                        TextSpan(
                          text: '${_data?.onumber ?? ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: Text(
                    _data?.odate != null
                        ? formatDateTime(DateTime.parse(_data!.odate!))
                        : '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.person_pin,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Text(
                        '${_data?.clientname ?? ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: _data?.items != null
                        ? _data!.items!
                            .map((service) => Service(
                                  service: service,
                                  handleRate: handleRate,
                                ))
                            .toList()
                        : [],
                  ),
                  if ((_data?.items?.length ?? 0) > 0)
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 32),
                      child: InkWell(
                        onTap: () => handleSubmit(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: containerGradient,
                          ),
                          width: 160,
                          height: 40,
                          alignment: Alignment.center,
                          child: (_status == 'loading')
                              ? Spinner()
                              : Text(
                                  'Үнэлгээ өгөх',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showMaterialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 30),
          backgroundColor: appColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          children: [
            if (_status == 'success')
              ModalContent(
                icon: Image(
                  image: AssetImage('lib/assets/3-stars.png'),
                  width: 120,
                ),
                text: Text(
                  'Манайхаар үйлчлүүлсэн таньд баярлалаа.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                hasBackButton: true,
              )
            else if (_status == 'overdue')
              ModalContent(
                icon: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 54,
                ),
                text: Text(
                  'Үйлчилгээнд үнэлгээ өгөх хугацаа хэтэрсэн байна.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                hasBackButton: true,
              )
            else if (_status == 'rated')
              ModalContent(
                icon: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 54,
                ),
                text: Text(
                  'Энэ үйлчилгээнд үнэлгээ өгсөн байна.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                hasBackButton: true,
              )
            else
              ModalContent(
                icon: Icon(
                  Icons.warning_amber_sharp,
                  color: Colors.white,
                  size: 54,
                ),
                text: Text(
                  'Сервертэй холбогдож чадсангүй, алдаа гарлаа.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                hasBackButton: false,
              ),
          ],
        );
      },
    );
  }
}

class Service extends StatefulWidget {
  const Service({
    Key? key,
    @required this.service,
    @required this.handleRate,
  }) : super(key: key);

  final service;
  final handleRate;

  @override
  _ServiceState createState() => _ServiceState();
}

class _ServiceState extends State<Service> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(
      milliseconds: 300,
    ),
    vsync: this,
  );

  void handleScale() {
    _controller.forward().whenComplete(() => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 8),
      padding: EdgeInsets.fromLTRB(12, 12, 12, 16),
      constraints: BoxConstraints(maxWidth: 490),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: containerShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.service.serviceName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Үйлчилгээ үзүүлсэн:   ',
                  ),
                  TextSpan(
                    text: widget.service.serviceBy,
                    style: TextStyle(
                      color: appColors.pink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<int>.generate(5, (i) => i + 1)
                  .map(
                    (item) => Star(
                      controller: _controller,
                      checked: (widget.service.rating ?? 0) >= item,
                      handleRate: widget.handleRate,
                      id: widget.service.id,
                      rating: item,
                      handleScale: handleScale,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Star extends AnimatedWidget {
  const Star({
    Key? key,
    required AnimationController controller,
    @required this.checked,
    @required this.handleRate,
    @required this.id,
    @required this.rating,
    @required this.handleScale,
  }) : super(key: key, listenable: controller);

  final checked;
  final handleRate;
  final id;
  final rating;
  final handleScale;

  Animation<double> get _scale => Tween(
        begin: 1.0,
        end: checked ? 1.3 : 1.0,
      ).animate(
        CurvedAnimation(
          parent: listenable as AnimationController,
          curve: Curves.easeInOut,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        child: ScaleTransition(
          scale: _scale,
          child: Icon(
            checked ? Icons.star_outlined : Icons.star_outline,
            color: Colors.yellow,
            size: 36,
          ),
        ),
        onTap: () => {
          handleScale(),
          handleRate(id, rating),
        },
      ),
    );
  }
}

class Spinner extends StatefulWidget {
  const Spinner({Key? key}) : super(key: key);

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(
      milliseconds: 600,
    ),
    vsync: this,
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Image(
        image: AssetImage('lib/assets/spinner.png'),
        color: Colors.white,
        width: 24,
        height: 24,
      ),
    );
  }
}

class ModalContent extends StatefulWidget {
  const ModalContent({
    Key? key,
    @required this.icon,
    @required this.text,
    @required this.hasBackButton,
  }) : super(key: key);

  final icon;
  final text;
  final hasBackButton;

  @override
  _ModalContentState createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: 600),
    vsync: this,
  )..forward();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutBack,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: ScaleTransition(
            scale: _animation,
            child: widget.icon,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20),
          child: widget.text,
        ),
        if (widget.hasBackButton == true)
          Container(
            margin: EdgeInsets.only(top: 30),
            child: BackToQrButton(),
          ),
      ],
    );
  }
}

class BackToQrButton extends StatelessWidget {
  const BackToQrButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 28,
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, qrReadRoute, ModalRoute.withName('/')),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: Colors.white,
            ),
            Text(
              'Буцах',
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          side: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

String formatDateTime(DateTime date) {
  String dateString =
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String timeString =
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  return '$dateString, $timeString';
}

class Data {
  bool? success;
  String? odate;
  String? onumber;
  String? clientname;
  List<Items>? items;

  Data({
    this.success,
    this.odate,
    this.onumber,
    this.clientname,
    this.items,
  });

  Data.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    odate = json['odate'];
    onumber = json['onumber'];
    clientname = json['clientname'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items?.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['odate'] = this.odate;
    data['onumber'] = this.onumber;
    data['clientname'] = this.clientname;
    if (this.items != null) {
      data['items'] = this.items?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? id;
  String? serviceBy;
  String? serviceName;
  int? rating;

  Items({
    this.id,
    this.serviceBy,
    this.serviceName,
    this.rating,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceBy = json['serviceBy'];
    serviceName = json['serviceName'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['serviceBy'] = this.serviceBy;
    data['serviceName'] = this.serviceName;
    data['rating'] = this.rating;
    return data;
  }
}
