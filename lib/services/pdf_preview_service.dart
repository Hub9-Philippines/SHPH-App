import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/services/logging_service.dart';

class PdfPreviewService {
  PdfPreviewService._();
  static final PdfPreviewService instance = PdfPreviewService._();

  Future<void> openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      LoggingService.error('Could not launch PDF URL: $url',
          tag: 'PdfPreviewService');
    }
  }

  Future<void> openFile(File file) async {
    final uri = file.uri;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      LoggingService.error('Could not open PDF file: ${file.path}',
          tag: 'PdfPreviewService');
    }
  }

  static Widget previewWidget(String url) {
    return _PdfPreview(url: url);
  }
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
            if (mounted) setState(() => _loading = false);
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
