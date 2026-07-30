import 'package:flutter/material.dart';

import '/components/error_state.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'provider_booking_flow_model.dart';

export 'provider_booking_flow_model.dart';

class ProviderBookingFlowWidget extends StatefulWidget {
  const ProviderBookingFlowWidget({
    super.key,
    required this.bookingId,
  });

  final String bookingId;

  static String routeName = 'ProviderBookingFlow';
  static String routePath = '/provider/booking/:bookingId';

  @override
  State<ProviderBookingFlowWidget> createState() =>
      _ProviderBookingFlowWidgetState();
}

class _ProviderBookingFlowWidgetState
    extends State<ProviderBookingFlowWidget> {
  late ProviderBookingFlowModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProviderBookingFlowModel.new);
    _model.loadBooking(widget.bookingId).then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: _model.step == 'completed'
          ? null
          : AppBar(
              backgroundColor: theme.primaryBackground,
              title: Text(_stepTitle, style: theme.titleMedium),
              centerTitle: true,
              elevation: 0,
            ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.fetchError != null
              ? Center(
                  child: ErrorState(
                  message: _model.fetchError!,
                  onRetry: () => _model
                      .loadBooking(widget.bookingId)
                      .then((_) => safeSetState(() {})),
                ))
              : _buildStepContent(theme),
    );
  }

  String get _stepTitle {
    switch (_model.step) {
      case 'accepted':
        return 'Job Accepted';
      case 'en_route':
        return 'On The Way';
      case 'arrived':
        return 'Arrived';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Booking';
    }
  }

  Widget _buildStepContent(AppThemeData theme) {
    switch (_model.step) {
      case 'accepted':
        return _buildAcceptedStep(theme);
      case 'en_route':
        return _buildEnRouteStep(theme);
      case 'arrived':
        return _buildArrivedStep(theme);
      case 'in_progress':
        return _buildInProgressStep(theme);
      case 'completed':
        return _buildCompletedStep(theme);
      default:
        return _buildAcceptedStep(theme);
    }
  }

  Widget _buildAcceptedStep(AppThemeData theme) {
    final b = _model.booking;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: theme.primary, size: 48),
              const SizedBox(height: 12),
              Text('Booking Accepted!',
                  style: theme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Head to the client\'s location to begin.',
                  style: theme.bodyMedium?.copyWith(color: theme.secondaryText)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoCard(theme, [
          _infoRow(theme, Icons.person, 'Client',
              b?['client_name']?.toString() ?? 'Client'),
          _infoRow(theme, Icons.build, 'Service',
              b?['listing_title']?.toString() ?? 'Service'),
          _infoRow(theme, Icons.calendar_today, 'Scheduled',
              b?['scheduled_at']?.toString() ?? ''),
          _infoRow(theme, Icons.attach_money, 'Total',
              '\$${_fmt(b?['total_price'])}'),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _model
                .updateStatus('en_route')
                .then((_) => safeSetState(() {})),
            icon: _model.transitioning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.navigation, size: 18),
            label: const Text("I'm On My Way"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnRouteStep(AppThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(theme, [
          _infoRow(theme, Icons.person, 'Client',
              _model.booking?['client_name']?.toString() ?? 'Client'),
          _infoRow(theme, Icons.location_on, 'Address',
              _model.booking?['client_address']?.toString() ?? ''),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _model
                .updateStatus('arrived')
                .then((_) => safeSetState(() {})),
            icon: _model.transitioning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle, size: 18),
            label: const Text('Arrived at Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrivedStep(AppThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.location_on, color: theme.success, size: 48),
              const SizedBox(height: 12),
              Text("You've Arrived",
                  style: theme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Verify with the client to start the service.',
                  style: theme.bodyMedium?.copyWith(color: theme.secondaryText)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _model
                .updateStatus('in_progress')
                .then((_) => safeSetState(() {})),
            icon: _model.transitioning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow, size: 18),
            label: const Text('Start Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressStep(AppThemeData theme) {
    final b = _model.booking;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border, width: 0.5),
          ),
          child: Column(
            children: [
              Text('Elapsed Working Time',
                  style: theme.bodySmall
                      ?.copyWith(color: theme.secondaryText)),
              const SizedBox(height: 8),
              Text(_model.elapsedDisplay,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoCard(theme, [
          _infoRow(theme, Icons.person, 'Client',
              b?['client_name']?.toString() ?? 'Client'),
          _infoRow(theme, Icons.build, 'Service',
              b?['listing_title']?.toString() ?? 'Service'),
          _infoRow(theme, Icons.attach_money, 'Total',
              '\$${_fmt(b?['total_price'])}'),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _model
                .updateStatus('completed')
                .then((_) => safeSetState(() {})),
            icon: _model.transitioning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle, size: 18),
            label: const Text('Complete Job'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedStep(AppThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: theme.success, size: 64),
              const SizedBox(height: 12),
              Text('Job Completed Successfully',
                  style: theme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Great work!',
                  style: theme.bodyMedium
                      ?.copyWith(color: theme.secondaryText)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to Dashboard'),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(AppThemeData theme, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow(
      AppThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.secondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.bodySmall
                        ?.copyWith(color: theme.secondaryText)),
                Text(value, style: theme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(dynamic val) {
    if (val == null) return '0';
    final n = val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return n.toStringAsFixed(0);
  }
}
