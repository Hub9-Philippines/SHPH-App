import 'package:flutter/material.dart';

import '/components/cupertino_ui/cupertino_page_header.dart';

class ImageLightbox extends StatefulWidget {
  const ImageLightbox({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  final String imageUrl;
  final String? heroTag;

  @override
  State<ImageLightbox> createState() => _ImageLightboxState();
}

class _ImageLightboxState extends State<ImageLightbox>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _animationController.forward(from: 0);
    final animation = Tween<Matrix4>(
      begin: _transformController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    animation.addListener(() {
      _transformController.value = animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          title: '',
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _resetZoom,
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onDoubleTap: _resetZoom,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.5,
            maxScale: 4.0,
            child: widget.heroTag != null
                ? Hero(
                    tag: widget.heroTag!,
                    child: Image.network(widget.imageUrl, fit: BoxFit.contain),
                  )
                : Image.network(widget.imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
