import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class IncomingJobModal extends StatefulWidget {
  const IncomingJobModal({
    super.key,
    required this.category,
    required this.description,
    this.clientName,
    this.distanceKm,
    this.clientRating,
    this.photoUrl,
    this.onAccept,
    this.onDecline,
    this.timeoutSeconds = 60,
  });

  final String category;
  final String description;
  final String? clientName;
  final double? distanceKm;
  final double? clientRating;
  final String? photoUrl;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final int timeoutSeconds;

  static Future<void> show(
    BuildContext context, {
    required String category,
    required String description,
    String? clientName,
    double? distanceKm,
    double? clientRating,
    String? photoUrl,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
    int timeoutSeconds = 60,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => IncomingJobModal(
        category: category,
        description: description,
        clientName: clientName,
        distanceKm: distanceKm,
        clientRating: clientRating,
        photoUrl: photoUrl,
        onAccept: onAccept,
        onDecline: onDecline,
        timeoutSeconds: timeoutSeconds,
      ),
    );
  }

  @override
  State<IncomingJobModal> createState() => _IncomingJobModalState();
}

class _IncomingJobModalState extends State<IncomingJobModal> {
  late int _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = widget.timeoutSeconds;
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: theme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.flash_on_rounded, size: 32, color: theme.warning),
                  ),
                ),
                Positioned(
                  right: -2, top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_countdown}s',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('New Job Request', style: theme.titleLarge),
          const SizedBox(height: 4),
          Text(widget.category, style: TextStyle(color: theme.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(widget.description, textAlign: TextAlign.center, style: TextStyle(color: theme.secondaryText, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.clientName != null) ...[
                Icon(Icons.person_rounded, size: 16, color: theme.secondaryText),
                const SizedBox(width: 4),
                Text(widget.clientName!, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
              ],
              if (widget.distanceKm != null) ...[
                Icon(Icons.near_me_rounded, size: 16, color: theme.secondaryText),
                const SizedBox(width: 4),
                Text('${widget.distanceKm!.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
              ],
              if (widget.clientRating != null) ...[
                Icon(Icons.star_rounded, size: 16, color: AppThemeData.star),
                const SizedBox(width: 4),
                Text(widget.clientRating!.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onDecline?.call();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: theme.error),
                      foregroundColor: theme.error,
                    ),
                    child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAccept?.call();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
