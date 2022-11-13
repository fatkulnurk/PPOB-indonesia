import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../../../widgets/web_view_render_html.dart';
import 'package:kerupiah_lite_app/helpers/config.dart' as config;

class NotificationHomePageScreen extends StatefulWidget {
  const NotificationHomePageScreen({Key? key}) : super(key: key);

  @override
  _NotificationHomePageState createState() => _NotificationHomePageState();
}

class _NotificationHomePageState extends State<NotificationHomePageScreen> {
  final controller = Completer<WebViewController>();
  String url = "${config.baseUrl}/api/web-views/notifications";
  @override
  void initState() {
    print(url);
    super.initState();
    print(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.home_outlined),
          )
        ],
        title: Text("Pemberitahuan"),
      ),
      body: SafeArea(
        child: WebViewRenderHtmlStack(
          controller: controller,
          url: url,
        ),
      ),
    );
  }
}