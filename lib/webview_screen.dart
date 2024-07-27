import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

class WebviewScreen extends StatefulWidget {
  final String appId;
  final String publicKey;
  final String type;
  final int? amount;
  final String? referenceId;
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? metaData;
  final Map<String, dynamic>? config;
  final Function(dynamic) success;
  final Function(dynamic) error;
  final Function(dynamic) close;
  const WebviewScreen({
    Key? key,
    required this.appId,
    required this.publicKey,
    required this.type,
    this.userData,
    this.metaData,
    this.config,
    this.amount,
    this.referenceId,
    required this.success,
    required this.error,
    required this.close,
  }) : super(key: key);

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? _webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
        clearCache: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  bool isGranted = false;
  bool isLocationGranted = false;
  dynamic locationData;
  dynamic timeZone;
  dynamic zoneOffset;
  dynamic locationObject;

  get blue => null;

  @override
  void initState() {
    super.initState();

    initPermissions();
  }

  Future initPermissions() async {
    if (await Permission.camera.request().isGranted) {
      setState(() {
        isGranted = true;
      });
    }
  }

  // Future initLocationPermissions() async {
  //   bool _serviceEnabled;

  //   Location location = Location();

  //   LocationData _locationData;

  //   PermissionStatus _permissionGranted;

  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }

  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   _locationData = await location.getLocation();

  //   final latitude = _locationData.latitude;

  //   final longitude = _locationData.longitude;

  //   DateTime dateTime = DateTime.now();

  //   final timeZoneName = dateTime.timeZoneName;
  //   final timeZoneOffset = dateTime.timeZoneOffset;

  //   final _locationObject = {
  //     "lat": latitude,
  //     "long": longitude,
  //     "timezone": timeZoneName,
  //     //"timezoneOffset" : timeZoneOffset,
  //   };

  //   // print("After Location data");
  //   // print(dateTime.timeZoneName);

  //   // print(latitude);
  //   // print(longitude);
  //   // print(dateTime.timeZoneOffset);

  //   //  print(_locationData);

  //   // print(json.encode(locationObject));

  //   if (await Permission.locationWhenInUse.request().isGranted) {
  //     setState(() {
  //       isLocationGranted = true;
  //       locationData = _locationData;
  //       timeZone = timeZoneName;
  //       zoneOffset = timeZoneOffset;
  //       locationObject = _locationObject;
  //     });
  //   }
  // }
  // returns an object with the following keys - latitude, longitude, and timezone

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: const Text("Dojah Widget"),
          //backgroundColor: ,
          ),
      body: isGranted
          ? InAppWebView(
              initialData: InAppWebViewInitialData(
                baseUrl: Uri.parse("https://widget.dojah.io"),
                androidHistoryUrl: Uri.parse("https://widget.dojah.io"),
                mimeType: "text/html",
                data: """
                      <html lang="en">
                        <head>
                            <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, shrink-to-fit=1"/>
                              
                            <title>Dojah Inc.</title>
                        </head>
                        <body>
                  
                        <script src="https://widget.dojah.io/widget.js"></script>
                        <script>
                                  const options = {
                                      app_id: "${widget.appId}",
                                      p_key: "${widget.publicKey}",
                                      type: "${widget.type}",
                                      config: ${json.encode(widget.config ?? {})},
                                      user_data: ${json.encode(widget.userData ?? {})},
                                      metadata: ${json.encode(widget.metaData ?? {})},
                                      __location: ${json.encode(locationObject ?? {})},
                                      amount: ${widget.amount},
                                      reference_id: ${widget.referenceId},
                                      onSuccess: function (response) {
                                      window.flutter_inappwebview.callHandler('onSuccessCallback', response)
                                      },
                                      onError: function (err) {
                                        window.flutter_inappwebview.callHandler('onErrorCallback', error)
                                      },
                                      onClose: function () {
                                        window.flutter_inappwebview.callHandler('onCloseCallback', 'close')
                                      }
                                  }
                                    const connect = new Connect(options);
                                    connect.setup();
                                    connect.open();
                              </script>
                        </body>
                      </html>
                  """,
              ),
              initialUrlRequest:
                  URLRequest(url: Uri.parse("https://widget.dojah.io")),
              initialOptions: options,
              onWebViewCreated: (controller) {
                _webViewController = controller;

                _webViewController?.addJavaScriptHandler(
                  handlerName: 'onSuccessCallback',
                  callback: (response) {
                    widget.success(response);
                  },
                );

                _webViewController?.addJavaScriptHandler(
                  handlerName: 'onCloseCallback',
                  callback: (response) {
                    widget.close(response);
                    if (response.first == 'close') {
                      Navigator.pop(context);
                    }
                  },
                );

                _webViewController?.addJavaScriptHandler(
                  handlerName: 'onErrorCallback',
                  callback: (error) {
                    widget.error(error);
                  },
                );
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
