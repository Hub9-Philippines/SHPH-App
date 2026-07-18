/// Build-time ICE configuration adapted from `feature/sync-from-shph-main`.
///
/// Production should provide first-party or approved servers with:
/// `SHPH_STUN_URLS`, `SHPH_TURN_URLS`, `SHPH_TURN_USERNAME`, and
/// `SHPH_TURN_CREDENTIAL`. Comma-separated URL lists are accepted.
class IceConfig {
  IceConfig._();

  static const _stunUrls = String.fromEnvironment(
    'SHPH_STUN_URLS',
    defaultValue: 'stun:stun.l.google.com:19302',
  );
  static const _turnUrls = String.fromEnvironment('SHPH_TURN_URLS');
  static const _turnUsername = String.fromEnvironment('SHPH_TURN_USERNAME');
  static const _turnCredential = String.fromEnvironment('SHPH_TURN_CREDENTIAL');

  static List<Map<String, dynamic>> iceServers({
    String stunUrls = _stunUrls,
    String turnUrls = _turnUrls,
    String turnUsername = _turnUsername,
    String turnCredential = _turnCredential,
  }) {
    final servers = <Map<String, dynamic>>[];
    final stun = _parseUrls(stunUrls, allowedSchemes: const {'stun', 'stuns'});
    if (stun.isNotEmpty) {
      servers.add({'urls': stun});
    }

    final turn = _parseUrls(turnUrls, allowedSchemes: const {'turn', 'turns'});
    if (turn.isNotEmpty &&
        turnUsername.trim().isNotEmpty &&
        turnCredential.isNotEmpty) {
      servers.add({
        'urls': turn,
        'username': turnUsername.trim(),
        'credential': turnCredential,
      });
    }
    return servers;
  }

  static Map<String, dynamic> configuration() => {
        'iceServers': iceServers(),
        'sdpSemantics': 'unified-plan',
        'iceCandidatePoolSize': 10,
        'bundlePolicy': 'max-bundle',
        'rtcpMuxPolicy': 'require',
      };

  static bool get hasTurnServer =>
      iceServers().any((server) => server.containsKey('credential'));

  static List<String> _parseUrls(
    String value, {
    required Set<String> allowedSchemes,
  }) {
    return value
        .split(',')
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .where((url) {
          final separator = url.indexOf(':');
          return separator > 0 &&
              allowedSchemes.contains(url.substring(0, separator));
        })
        .toSet()
        .toList(growable: false);
  }
}
