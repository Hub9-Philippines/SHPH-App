import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/models/room.dart';

void main() {
  test('parses the deployed nested room schema', () {
    final room = ShphRoom.fromJson({
      'id': '0123456789abcdef01234567',
      'title': 'Shared catering',
      'category': '4',
      'heads_required': '10',
      'price_per_head': '250.50',
      'event_date': '2026-08-01',
      'event_time': '10:30',
      'latitude': '14.5',
      'seats_remaining': 2,
      'participants': [
        {
          'id': 1,
          'user': 9,
          'role': 'organizer',
          'status': 'paid',
          'booking': 'abcdefabcdefabcdefabcdef',
        },
      ],
    });

    expect(room.category, 4);
    expect(room.headsRequired, 10);
    expect(room.pricePerHead, 250.5);
    expect(room.latitude, 14.5);
    expect(room.canJoin, isTrue);
    expect(room.participants.single.booking, 'abcdefabcdefabcdefabcdef');
    expect(room.participants.single.isOrganizer, isTrue);
  });

  test('full, cancelled, and zero-seat rooms cannot be joined', () {
    ShphRoom room({
      String status = 'open',
      bool full = false,
      int seats = 1,
    }) =>
        ShphRoom(
          id: '0123456789abcdef01234567',
          title: 'Room',
          category: 1,
          headsRequired: 2,
          pricePerHead: 100,
          eventDate: '2026-08-01',
          eventTime: '10:00',
          status: status,
          isFull: full,
          seatsRemaining: seats,
        );

    expect(room().canJoin, isTrue);
    expect(room(full: true).canJoin, isFalse);
    expect(room(status: 'cancelled').canJoin, isFalse);
    expect(room(seats: 0).canJoin, isFalse);
  });
}
