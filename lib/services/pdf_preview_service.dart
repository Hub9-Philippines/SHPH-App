import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/services/logging_service.dart';

/// Opens PDF documents externally or renders a remote document in a WebView.
class PdfPreviewService {
  PdfPreviewService._();

  static final PdfPreviewService instance = PdfPreviewService._();

  Future<bool> openExternal(String url) async {
    return _launch(Uri.parse(url), LaunchMode.externalApplication);
  }

  Future<bool> openFile(File file) async {
    return _launch(file.uri, LaunchMode.externalApplication);
  }

  Future<bool> _launch(Uri uri, LaunchMode mode) async {
    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: mode);
      }
    } catch (error, stackTrace) {
      LoggingService.error(
        'Unable to open PDF: $uri',
        tag: 'PdfPreviewService',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }

    LoggingService.warning(
      'No application can open PDF: $uri',
      tag: 'PdfPreviewService',
    );
    return false;
  }

  static Widget previewWidget(String url) => _PdfPreview(url: url);
}

class _PdfPreview extends StatefulWidget {
  const _PdfPreview({required this.url});

  final String url;

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
