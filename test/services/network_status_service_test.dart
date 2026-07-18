import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/network_status_service.dart';

void main() {
  test('reports and emits changes from an injected SHPH probe', () async {
    var online = false;
    final service = NetworkStatusService(
      probe: () async => online,
      interval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);

    final changes = <bool>[];
    final subscription = service.onOnlineChanged.listen(changes.add);
    addTearDown(subscription.cancel);

    expect(await service.checkConnection(), isFalse);
    online = true;
    expect(await service.checkConnection(), isTrue);
    await Future<void>.delayed(Duration.zero);

    expect(changes, [false, true]);
  });

  test('initialize is idempotent and stop permits restarting', () async {
    var probes = 0;
    final service = NetworkStatusService(
      probe: () async {
        probes++;
        return true;
      },
      interval: const Duration(hours: 1),
    );
    addTearDown(service.dispose);

    await service.initialize();
    await service.initialize();
    expect(probes, 1);

    service.stop();
    await service.initialize();
    expect(probes, 2);
  });

  test('probe exceptions are treated as offline', () async {
    final service = NetworkStatusService(
      probe: () async => throw const SocketExceptionForTest(),
    );
    addTearDown(service.dispose);

    expect(await service.checkConnection(), isFalse);
    expect(service.isOnline, isFalse);
  });
}

class SocketExceptionForTest implements Exception {
  const SocketExceptionForTest();
}
