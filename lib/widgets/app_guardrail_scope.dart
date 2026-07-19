import 'dart:async';

import 'package:flutter/material.dart';

import '/services/network_status_service.dart';
import '/services/session_timeout_service.dart';

/// Applies the network and session guardrails from
/// `feature/sync-from-shph-main` around the routed application content.
///
/// The source branch supplied the services but did not integrate them at the
/// app root; this wrapper completes that integration for the current router.
class AppGuardrailScope extends StatefulWidget {
  const AppGuardrailScope({
    required this.authenticated,
    required this.onSessionTimeout,
    required this.child,
    this.networkStatusService,
    this.sessionTimeoutService,
    super.key,
  });

  final bool authenticated;
  final Future<void> Function() onSessionTimeout;
  final Widget child;
  final NetworkStatusService? networkStatusService;
  final SessionTimeoutService? sessionTimeoutService;

  @override
  State<AppGuardrailScope> createState() => _AppGuardrailScopeState();
}

class _AppGuardrailScopeState extends State<AppGuardrailScope>
    with WidgetsBindingObserver {
  late final NetworkStatusService _network;
  late final SessionTimeoutService _session;
  StreamSubscription<bool>? _networkSubscription;
  StreamSubscription<SessionTimeoutEvent>? _sessionSubscription;
  bool _online = true;
  bool _handlingTimeout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _network = widget.networkStatusService ?? NetworkStatusService.instance;
    _session = widget.sessionTimeoutService ?? SessionTimeoutService.instance;
    _online = _network.isOnline;
    _networkSubscription = _network.onOnlineChanged.listen(_onNetworkChanged);
    _sessionSubscription = _session.events.listen(_onSessionEvent);
    unawaited(_network.initialize());
    _syncSessionState();
  }

  @override
  void didUpdateWidget(covariant AppGuardrailScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authenticated != widget.authenticated) {
      _syncSessionState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_network.checkConnection());
      _recordActivity();
    }
  }

  void _syncSessionState() {
    if (widget.authenticated) {
      _session.start();
    } else {
      _session.stop();
    }
  }

  void _recordActivity() {
    if (widget.authenticated) {
      _session.recordActivity();
    }
  }

  void _onNetworkChanged(bool online) {
    if (mounted && online != _online) {
      setState(() => _online = online);
    }
  }

  void _onSessionEvent(SessionTimeoutEvent event) {
    if (!mounted || !widget.authenticated) {
      return;
    }
    switch (event) {
      case SessionTimeoutEvent.warning:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('Your session will expire in 2 minutes.'),
            duration: Duration(seconds: 6),
          ),
        );
        return;
      case SessionTimeoutEvent.timedOut:
        unawaited(_handleTimeout());
    }
  }

  Future<void> _handleTimeout() async {
    if (_handlingTimeout) {
      return;
    }
    _handlingTimeout = true;
    _session.stop();
    try {
      await widget.onSessionTimeout();
    } finally {
      _handlingTimeout = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _networkSubscription?.cancel();
    _sessionSubscription?.cancel();
    _network.stop();
    _session.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _recordActivity(),
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          widget.child,
          if (!_online)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Material(
                  color: const Color(0xFFD84315),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'No connection to SerbisyoHub. Some actions are unavailable.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              unawaited(_network.checkConnection()),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
