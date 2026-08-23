import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({required this.isOffline, super.key});

  final bool isOffline;

  @override
  Widget build(BuildContext context) => AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isOffline ? Offset.zero : const Offset(0, -2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isOffline ? 36 : 0,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
          ),
        ),
        child: isOffline
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
}
