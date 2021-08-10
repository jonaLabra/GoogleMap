import 'dart:async';

import 'package:example/src/provider/maps_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart' as webView;
import 'package:provider/provider.dart';

class WebStreetView extends StatefulWidget {
  const WebStreetView({Key key}) : super(key: key);

  @override
  _WebStreetViewState createState() => _WebStreetViewState();
}

class _WebStreetViewState extends State<WebStreetView> {
  String url =
      'https://www.google.com/maps/@18.644535,-99.1619464,3a,75y,90t/data=!3m6!1e1!3m4!1sj_T8BvOeKA42HKkptu_A2A!2e0!7i13312!8i6656';
  final Completer<webView.WebViewController> completer =
      Completer<webView.WebViewController>();
  ScreenshotController screenshotController = ScreenshotController();
  InAppWebViewController inwebView;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return inAppWebViewScreen(url);
  }

  Widget webViewScreen() {
    return ChangeNotifierProvider<Maps_Data>(
        create: (context) => Maps_Data(),
        child: Consumer<Maps_Data>(builder: (_, value, __) {
          value.getControllerScreen(screenshotController, context);
          return Container(
            width: 450,
            height: 450,
            child: Screenshot(
                controller: screenshotController,
                child: Center(
                  child: Text('sahfhnapofjoaspfjdopasjodsa'),
                )),
          );
        }));
  }

  Widget inAppWebViewScreen(url) {
    return ChangeNotifierProvider<Maps_Data>(
        create: (context) => Maps_Data(),
        child: Consumer<Maps_Data>(builder: (_, value, __) {
          return Container(
            width: 450,
            height: 450,
            child: InAppWebView(
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptCanOpenWindowsAutomatically: true,
                ),
              ),
              initialUrlRequest: URLRequest(
                url: Uri.parse(url),
              ),
              onWebViewCreated: (controller) {
                value.getController(controller, context);
                print('Mapa creado');
              },
            ),
          );
        }));
  }

  Widget otherWebView(url) {
    return WebviewScaffold(
      url: url,
      appBar: AppBar(
        title: const Text('Widget webview'),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        color: Colors.redAccent,
        child: const Center(
          child: Text('Waiting.....'),
        ),
      ),
    );
  }
}
