/// ICE/STUN/TURN configuration for WebRTC peer connections.
///
/// TURN credentials are injected at build time:
///   --dart-define=SHPH_TURN_USERNAME=... --dart-define=SHPH_TURN_CREDENTIAL=...
class IceConfig {
  IceConfig._();

  static const String _turnUser =
      String.fromEnvironment('SHPH_TURN_USERNAME', defaultValue: '');
  static const String _turnCred =
      String.fromEnvironment('SHPH_TURN_CREDENTIAL', defaultValue: '');

  static List<Map<String, dynamic>> iceServers({
    String turnUser = _turnUser,
    String turnCred = _turnCred,
  }) {
    final servers = <Map<String, dynamic>>[
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
        ],
      },
    ];
    if (turnUser.isNotEmpty && turnCred.isNotEmpty) {
      servers.add({
        'urls': [
          'turn:web.prepcirca.com:3478?transport=udp',
          'turn:web.prepcirca.com:3478?transport=tcp',
          'turns:web.prepcirca.com:5349?transport=tcp',
        ],
        'username': turnUser,
        'credential': turnCred,
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
}
