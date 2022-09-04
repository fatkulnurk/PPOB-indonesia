import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class WebViewRenderHtmlStack extends StatefulWidget {
  WebViewRenderHtmlStack(
      {required this.controller, required this.url, Key? key})
      : super(key: key); // Modify

  final Completer<WebViewController> controller;
  final String url;

  @override
  State<WebViewRenderHtmlStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewRenderHtmlStack> {
  var loadingPercentage = 0;
  String html = '';

  Future<void> getInitializeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var url = Uri.parse(widget.url);
    var response = await http.get(url, headers: <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      setState(() {
        html = response.body;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInitializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (html != '')
          WebView(
            // initialUrl: widget.url,
            onWebViewCreated: (webViewController) {
              // webViewController.loadUrl(
              // Uri.dataFromString(html, mimeType: 'text/html').toString());
              webViewController.loadHtmlString(html);
            },
            onPageStarted: (url) {
              setState(() {
                loadingPercentage = 0;
              });
            },
            onProgress: (progress) {
              setState(() {
                loadingPercentage = progress;
              });
            },
            onPageFinished: (url) {
              setState(() {
                loadingPercentage = 100;
              });
            },
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (navigation) async {
              if (!navigation.url.contains(config.baseUrl)) {
                if (!await launchUrlString(
                  navigation.url,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw 'Could not launch $navigation.url';
                }

                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            },
          ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
            color: Colors.yellowAccent,
            backgroundColor: Colors.black,
          ),
      ],
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({required this.controller, Key? key})
      : super(key: key);

  final Completer<WebViewController> controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller.future,
      builder: (context, snapshot) {
        final WebViewController? controller = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done ||
            controller == null) {
          return Row(
            children: const <Widget>[
              Icon(Icons.arrow_back_ios),
              Icon(Icons.arrow_forward_ios),
              Icon(Icons.replay),
            ],
          );
        }

        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No back history item')),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No forward history item')),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                controller.reload();
              },
            ),
          ],
        );
      },
    );
  }
}
