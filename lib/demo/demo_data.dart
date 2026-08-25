import 'package:dio/dio.dart';

class DemoReply {
  const DemoReply(this.status, this.body);
  final int status;
  final Object? body;
}

class DemoData {
  DemoData._();

  static String currentRole = 'client';
  static int _nextBookingId = 9000;
  static int _nextRoomId = 500;

  static bool get isProvider => currentRole == 'provider';

  static Map<String, dynamic> get currentUser =>
      isProvider ? providerUser : clientUser;

  static Map<String, dynamic> userForEmail(String email) => clientUser;

  static Map<String, dynamic> get clientUser => const {
        'id': 101,
        'email': 'juan.demo@serbisyohub.ph',
        'display_name': 'Juan Dela Cruz',
        'first_name': 'Juan',
        'last_name': 'Dela Cruz',
        'phone': '+63 917 555 0101',
        'photo_url': null,
        'role': 'client',
        'is_client': true,
        'is_provider': false,
        'email_verified': true,
        'kyc_skipped': false,
        'date_joined': '2026-01-12T08:30:00Z',
      };

  static Map<String, dynamic> get providerUser => const {
        'id': 201,
        'email': 'maria.demo@serbisyohub.ph',
        'display_name': 'Maria Santos',
        'first_name': 'Maria',
        'last_name': 'Santos',
        'phone': '+63 917 555 0202',
        'photo_url': null,
        'role': 'provider',
        'is_client': true,
        'is_provider': true,
        'email_verified': true,
        'kyc_skipped': false,
        'date_joined': '2025-11-03T10:00:00Z',
      };

  static List<Map<String, dynamic>> get providers => [
        {
          'id': 201,
          'display_name': 'Maria Santos',
          'photo_url': null,
          'role': 'provider',
          'is_provider': true,
          'bio': 'Licensed electrician with 8 years of residential experience.',
          'city': 'Quezon City',
          'province': 'Metro Manila',
          'rating': '4.9',
          'review_count': 132,
          'completed_jobs': 214,
          'is_verified': true,
        },
        {
          'id': 202,
          'display_name': 'Carlo Reyes',
          'photo_url': null,
          'role': 'provider',
          'is_provider': true,
          'bio': 'Certified plumber specializing in leak repair and repiping.',
          'city': 'Makati',
          'province': 'Metro Manila',
          'rating': '4.7',
          'review_count': 88,
          'completed_jobs': 141,
          'is_verified': true,
        },
        {
          'id': 203,
          'display_name': 'Ana Lim',
          'photo_url': null,
          'role': 'provider',
          'is_provider': true,
          'bio': 'Home cleaning professional, pet-friendly, eco supplies.',
          'city': 'Pasig',
          'province': 'Metro Manila',
          'rating': '4.8',
          'review_count': 205,
          'completed_jobs': 322,
          'is_verified': true,
        },
        {
          'id': 204,
          'display_name': 'Paolo Mendoza',
          'photo_url': null,
          'role': 'provider',
          'is_provider': true,
          'bio': 'Aircon installation and deep cleaning specialist.',
          'city': 'Taguig',
          'province': 'Metro Manila',
          'rating': '4.6',
          'review_count': 64,
          'completed_jobs': 97,
          'is_verified': false,
        },
      ];

  static List<Map<String, dynamic>> get categories => [
        {'id': 1, 'name': 'Electrical', 'slug': 'electrical'},
        {'id': 2, 'name': 'Plumbing', 'slug': 'plumbing'},
        {'id': 3, 'name': 'Cleaning', 'slug': 'cleaning'},
        {'id': 4, 'name': 'Aircon & HVAC', 'slug': 'aircon-hvac'},
        {'id': 5, 'name': 'Carpentry', 'slug': 'carpentry'},
        {'id': 6, 'name': 'Appliance Repair', 'slug': 'appliance-repair'},
        {'id': 7, 'name': 'Tutoring', 'slug': 'tutoring'},
        {'id': 8, 'name': 'Beauty & Wellness', 'slug': 'beauty-wellness'},
      ];

  static List<Map<String, dynamic>> subcategoriesFor(int parentId) {
    const map = {
      1: [
        {'id': 11, 'name': 'Wiring & Rewiring'},
        {'id': 12, 'name': 'Light Installation'},
        {'id': 13, 'name': 'Outlet Repair'},
      ],
      2: [
        {'id': 21, 'name': 'Leak Repair'},
        {'id': 22, 'name': 'Drain Cleaning'},
      ],
      3: [
        {'id': 31, 'name': 'Deep Cleaning'},
        {'id': 32, 'name': 'Move-in/out Cleaning'},
      ],
      4: [
        {'id': 41, 'name': 'Aircon Cleaning'},
        {'id': 42, 'name': 'Installation'},
      ],
    };
    return (map[parentId] ?? const [])
        .map((e) => {...e, 'parent': parentId})
        .toList();
  }

  static List<Map<String, dynamic>> get listings => [
        _listing(1, 'Home Electrical Wiring Check', 1, 'Electrical', 201,
            'Maria Santos', 850, 'per visit', '4.9', 34, 'Quezon City'),
        _listing(2, 'Emergency Leak Repair', 2, 'Plumbing', 202, 'Carlo Reyes',
            650, 'per hour', '4.7', 51, 'Makati'),
        _listing(3, 'Weekly Home Deep Cleaning', 3, 'Cleaning', 203, 'Ana Lim',
            1200, 'per session', '4.8', 89, 'Pasig'),
        _listing(4, 'Split-type Aircon Cleaning', 4, 'Aircon & HVAC', 204,
            'Paolo Mendoza', 700, 'per unit', '4.6', 40, 'Taguig'),
        _listing(5, 'Light Fixture Installation', 1, 'Electrical', 201,
            'Maria Santos', 500, 'per fixture', '4.9', 22, 'Quezon City'),
        _listing(6, 'Clogged Drain Unclogging', 2, 'Plumbing', 202,
            'Carlo Reyes', 550, 'per drain', '4.5', 18, 'Makati'),
        _listing(7, 'Post-Construction Cleaning', 3, 'Cleaning', 203, 'Ana Lim',
            2500, 'per session', '4.9', 31, 'Pasig'),
        _listing(8, 'Window Type Aircon Repair', 4, 'Aircon & HVAC', 204,
            'Paolo Mendoza', 900, 'per visit', '4.4', 15, 'Taguig'),
        _listing(9, 'Custom Shelving & Cabinets', 5, 'Carpentry', 202,
            'Carlo Reyes', 1800, 'per project', '4.8', 27, 'Makati'),
        _listing(10, 'Washing Machine Repair', 6, 'Appliance Repair', 204,
            'Paolo Mendoza', 750, 'per visit', '4.5', 33, 'Taguig'),
        _listing(11, 'Math Tutoring (Grade 7-10)', 7, 'Tutoring', 203, 'Ana Lim',
            400, 'per hour', '5.0', 47, 'Pasig'),
        _listing(12, 'Home Massage Therapy', 8, 'Beauty & Wellness', 203,
            'Ana Lim', 800, 'per session', '4.9', 58, 'Pasig'),
      ];

  static Map<String, dynamic> _listing(
      int id,
      String title,
      int catId,
      String catName,
      int providerId,
      String providerName,
      num price,
      String unit,
      String rating,
      int reviews,
      String city) {
    return {
      'id': id,
      'title': title,
      'category': catId,
      'category_name': catName,
      'provider': providerId,
      'provider_name': providerName,
      'provider_photo': null,
      'description':
          '$title by $providerName. Professional service with quality guarantee. Serving $city and nearby areas.',
      'base_price': price.toDouble(),
      'price_unit': unit,
      'status': 'active',
      'is_available': 'true',
      'rating': rating,
      'thumbnail': null,
      'review_count': reviews,
      'created_at': '2026-02-15T09:00:00Z',
      'city': city,
      'province': 'Metro Manila',
      'latitude': 14.6 + id * 0.001,
      'longitude': 121.0 + id * 0.001,
      'distance_km': 1.2 + id * 0.7,
      'is_time_material': false,
    };
  }

  static List<Map<String, dynamic>> bookings = [
    _booking(301, 1, 'pending', 'Maria Santos', '2026-08-28', '14:00:00', 850,
        null, 'Quezon City',
        notes: 'Check bedroom outlets'),
    _booking(302, 3, 'confirmed', 'Ana Lim', '2026-08-26', '09:00:00', 1200,
        null, 'Pasig'),
    _booking(303, 2, 'arrived', 'Carlo Reyes', '2026-08-25', '13:00:00', 650,
        '10:05:00', 'Makati'),
    _booking(304, 4, 'in_progress', 'Paolo Mendoza', '2026-08-25', '08:00:00',
        700, '07:55:00', 'Taguig',
        startedAt: '08:10:00'),
    _booking(305, 5, 'completed', 'Maria Santos', '2026-08-20', '15:00:00',
        1000, '14:50:00', 'Quezon City',
        startedAt: '15:05:00',
        completedAt: '2026-08-20T17:30:00Z'),
    _booking(306, 3, 'completed', 'Ana Lim', '2026-08-13', '09:00:00', 1200,
        '08:45:00', 'Pasig',
        startedAt: '09:00:00', completedAt: '2026-08-13T12:00:00Z'),
    _booking(307, 6, 'cancelled', 'Carlo Reyes', '2026-08-18', '11:00:00', 550,
        null, 'Makati',
        cancelled: true),
  ];

  static Map<String, dynamic> _booking(
      int id,
      int listingId,
      String status,
      String providerName,
      String date,
      String time,
      num agreed,
      String? arrivedAt,
      String address,
      {String? notes,
      String? startedAt,
      String? completedAt,
      bool cancelled = false}) {
    final listing = byId(listings, '$listingId') ?? listings.first;
    return {
      'id': id,
      'listing': listingId,
      'status': status,
      'listing_title': listing['title'],
      'provider_id': listing['provider'],
      'provider_name': providerName,
      'provider_photo': null,
      'client_id': 101,
      'client_name': currentUser['display_name'],
      'scheduled_date': date,
      'scheduled_time': time,
      'scheduled_at': '${date}T$time',
      'notes': notes,
      'agreed_price': agreed.toDouble(),
      'total_price': agreed.toDouble(),
      'created_at':
          '2026-08-${(10 + id % 15).toString().padLeft(2, '0')}T08:00:00Z',
      'arrived_at': arrivedAt == null ? null : '${date}T$arrivedAt',
      'started_at': startedAt == null ? null : '${date}T$startedAt',
      'completed_at': completedAt,
      'client_address': '$address, Metro Manila',
      'service_lat': 14.62 + id * 0.0005,
      'service_lng': 121.02 + id * 0.0005,
      'service_listings': listing,
      'profiles': {
        'id': 101,
        'display_name': currentUser['display_name'],
        'photo_url': null,
        'phone': '+63 917 555 0101',
      },
      if (status == 'cancelled') 'cancel_reason': 'Schedule conflict',
    };
  }

  static Map<String, dynamic>? byId(List<Map<String, dynamic>> list, String? id) {
    if (id == null) return null;
    for (final item in list) {
      if ('${item['id']}' == id) return item;
    }
    return null;
  }

  static List<Map<String, dynamic>> get reviews => [
        {
          'id': 71,
          'listing': 1,
          'booking': 305,
          'client': 101,
          'client_name': 'Juan Dela Cruz',
          'rating': 5,
          'comment':
              'Maria was punctual and fixed all our wiring issues. Highly recommended!',
          'created_at': '2026-08-21T10:00:00Z',
          'listing_title': 'Home Electrical Wiring Check',
          'provider': 201,
          'provider_name': 'Maria Santos',
        },
        {
          'id': 72,
          'listing': 3,
          'booking': 306,
          'client': 101,
          'client_name': 'Juan Dela Cruz',
          'rating': 5,
          'comment': 'House spotless after the deep cleaning session.',
          'created_at': '2026-08-14T09:30:00Z',
          'listing_title': 'Weekly Home Deep Cleaning',
          'provider': 203,
          'provider_name': 'Ana Lim',
        },
        {
          'id': 73,
          'listing': 1,
          'client': 102,
          'client_name': 'Liwayway Garcia',
          'rating': 4,
          'comment': 'Good work, arrived slightly late but very thorough.',
          'created_at': '2026-07-30T15:00:00Z',
          'listing_title': 'Home Electrical Wiring Check',
          'provider': 201,
          'provider_name': 'Maria Santos',
        },
      ];

  static List<Map<String, dynamic>> get addresses => [
        {
          'id': 81,
          'label': 'Home',
          'street': '123 Katipunan Ave',
          'barangay': 'Loyola Heights',
          'city': 'Quezon City',
          'province': 'Metro Manila',
          'zip_code': '1108',
          'is_default': true,
          'latitude': 14.636,
          'longitude': 121.078,
        },
        {
          'id': 82,
          'label': 'Office',
          'street': '5th Ave, Bonifacio Global City',
          'barangay': 'Fort Bonifacio',
          'city': 'Taguig',
          'province': 'Metro Manila',
          'zip_code': '1634',
          'is_default': false,
          'latitude': 14.554,
          'longitude': 121.05,
        },
      ];

  static List<Map<String, dynamic>> get threads => [
        {
          'id': 501,
          'participant_names': ['Maria Santos'],
          'other_user_name': 'Maria Santos',
          'other_user_photo': null,
          'last_message': 'On my way, see you at 2pm!',
          'last_message_at': '2026-08-25T13:42:00Z',
          'unread_count': 1,
          'booking': 301,
          'listing_title': 'Home Electrical Wiring Check',
        },
        {
          'id': 502,
          'participant_names': ['Ana Lim'],
          'other_user_name': 'Ana Lim',
          'other_user_photo': null,
          'last_message': 'Deep cleaning confirmed for Wednesday.',
          'last_message_at': '2026-08-24T18:20:00Z',
          'unread_count': 0,
          'booking': 302,
          'listing_title': 'Weekly Home Deep Cleaning',
        },
        {
          'id': 503,
          'participant_names': ['Paolo Mendoza'],
          'other_user_name': 'Paolo Mendoza',
          'other_user_photo': null,
          'last_message': 'Aircon is running cold again. Salamat!',
          'last_message_at': '2026-08-23T16:05:00Z',
          'unread_count': 0,
          'booking': 304,
          'listing_title': 'Split-type Aircon Cleaning',
        },
      ];

  static List<Map<String, dynamic>> messagesFor(int threadId) {
    final base = <int, List<Map<String, dynamic>>>{
      501: [
        {
          'id': 1,
          'content': 'Hi Maria, are you available this Friday?',
          'sender_id': 101,
          'sender_name': 'Juan Dela Cruz',
          'created_at': '2026-08-25T13:30:00Z'
        },
        {
          'id': 2,
          'content': 'Yes! 2pm works for me.',
          'sender_id': 201,
          'sender_name': 'Maria Santos',
          'created_at': '2026-08-25T13:35:00Z'
        },
        {
          'id': 3,
          'content': 'On my way, see you at 2pm!',
          'sender_id': 201,
          'sender_name': 'Maria Santos',
          'created_at': '2026-08-25T13:42:00Z'
        },
      ],
      502: [
        {
          'id': 4,
          'content': 'Wednesday 9am still good?',
          'sender_id': 101,
          'sender_name': 'Juan Dela Cruz',
          'created_at': '2026-08-24T18:10:00Z'
        },
        {
          'id': 5,
          'content': 'Deep cleaning confirmed for Wednesday.',
          'sender_id': 203,
          'sender_name': 'Ana Lim',
          'created_at': '2026-08-24T18:20:00Z'
        },
      ],
      503: [
        {
          'id': 6,
          'content': 'Done po! Aircon is running cold again. Salamat!',
          'sender_id': 204,
          'sender_name': 'Paolo Mendoza',
          'created_at': '2026-08-23T16:05:00Z'
        },
      ],
    };
    return base[threadId] ?? [];
  }

  static List<Map<String, dynamic>> notifications = [
        {
          'id': 91,
          'title': 'Booking Confirmed',
          'body': 'Ana Lim confirmed your deep cleaning on Aug 26, 9:00 AM.',
          'is_read': false,
          'type': 'booking',
          'redirect_url': '/bookingDetails/302',
          'created_at': '2026-08-24T18:20:00Z',
        },
        {
          'id': 92,
          'title': 'Provider Arrived',
          'body': 'Carlo Reyes has arrived at your address.',
          'is_read': false,
          'type': 'booking',
          'redirect_url': '/bookingDetails/303',
          'created_at': '2026-08-25T10:05:00Z',
        },
        {
          'id': 93,
          'title': 'New Message',
          'body': 'Maria Santos: On my way, see you at 2pm!',
          'is_read': true,
          'type': 'message',
          'redirect_url': '/chatPage/501',
          'created_at': '2026-08-25T13:42:00Z',
        },
        {
          'id': 94,
          'title': 'Payout Processed',
          'body': 'Your payout of PHP 3,200.00 has been sent.',
          'is_read': true,
          'type': 'earnings',
          'redirect_url': '/wallet',
          'created_at': '2026-08-21T09:00:00Z',
        },
      ];

  static Map<String, dynamic> get earningsSummary => {
        'total_earnings': 48750.0,
        'available_balance': 3200.0,
        'pending_balance': 1450.0,
        'withdrawn_total': 44100.0,
        'this_month': 8600.0,
        'last_month': 11250.0,
        'currency': 'PHP',
      };

  static List<Map<String, dynamic>> get earningsTransactions => [
        {
          'id': 61,
          'type': 'earning',
          'amount': 1000.0,
          'status': 'cleared',
          'description': 'Light Fixture Installation - Juan D.',
          'created_at': '2026-08-20T17:30:00Z'
        },
        {
          'id': 62,
          'type': 'earning',
          'amount': 1200.0,
          'status': 'cleared',
          'description': 'Deep Cleaning - Juan D.',
          'created_at': '2026-08-13T12:00:00Z'
        },
        {
          'id': 63,
          'type': 'payout',
          'amount': -3200.0,
          'status': 'paid',
          'description': 'GCash payout',
          'created_at': '2026-08-21T09:00:00Z'
        },
        {
          'id': 64,
          'type': 'earning',
          'amount': 700.0,
          'status': 'pending',
          'description': 'Aircon Cleaning - Juan D.',
          'created_at': '2026-08-25T08:30:00Z'
        },
      ];

  static List<Map<String, dynamic>> get payouts => [
        {
          'id': 65,
          'amount': 3200.0,
          'status': 'paid',
          'payment_method': 'GCash',
          'reference': 'PO-2026-0065',
          'created_at': '2026-08-21T09:00:00Z'
        },
        {
          'id': 66,
          'amount': 5400.0,
          'status': 'paid',
          'payment_method': 'Bank Transfer',
          'reference': 'PO-2026-0066',
          'created_at': '2026-07-28T09:00:00Z'
        },
      ];

  static Map<String, dynamic> get providerAnalytics => {
        'period': 'month',
        'total_bookings': 38,
        'completed_bookings': 33,
        'cancelled_bookings': 3,
        'revenue': 48750.0,
        'avg_rating': 4.8,
        'profile_views': 1240,
        'conversion_rate': 0.32,
        'labels': ['May', 'Jun', 'Jul', 'Aug'],
        'values': [8200.0, 10400.0, 11250.0, 8600.0],
      };

  static List<Map<String, dynamic>> get availabilitySlots => [
        {
          'id': 401,
          'date': '2026-08-27',
          'start_time': '09:00:00',
          'end_time': '12:00:00',
          'is_available': true
        },
        {
          'id': 402,
          'date': '2026-08-27',
          'start_time': '13:00:00',
          'end_time': '17:00:00',
          'is_available': true
        },
        {
          'id': 403,
          'date': '2026-08-28',
          'start_time': '08:00:00',
          'end_time': '12:00:00',
          'is_available': false
        },
      ];

  static List<Map<String, dynamic>> get projects => [
        {
          'id': 701,
          'title': 'Renovate condo kitchen',
          'description': 'Full kitchen remodel including cabinets and countertops.',
          'status': 'open',
          'budget_min': 60000,
          'budget_max': 90000,
          'client': 101,
          'client_name': 'Juan Dela Cruz',
          'quotes_count': 2,
          'created_at': '2026-08-19T10:00:00Z'
        },
        {
          'id': 702,
          'title': 'Install CCTV for shop',
          'description': '4-camera CCTV setup for a small retail space.',
          'status': 'matched',
          'budget_min': 15000,
          'budget_max': 25000,
          'client': 101,
          'client_name': 'Juan Dela Cruz',
          'quotes_count': 1,
          'created_at': '2026-08-15T14:30:00Z'
        },
      ];

  static List<Map<String, dynamic>> get rooms => [
        {
          'id': 801,
          'name': 'Kitchen Renovation Planning',
          'join_token': 'demo-room-801',
          'is_locked': false,
          'members_count': 3,
          'created_at': '2026-08-19T11:00:00Z',
          'host': 101
        },
        {
          'id': 802,
          'name': 'CCTV Install Coordination',
          'join_token': 'demo-room-802',
          'is_locked': true,
          'members_count': 2,
          'created_at': '2026-08-16T09:00:00Z',
          'host': 101
        },
      ];

  static List<Map<String, dynamic>> get disputes => [
        {
          'id': 851,
          'booking': 307,
          'reason': 'Provider cancelled last minute',
          'status': 'open',
          'description': 'Provider cancelled on the day of service.',
          'created_at': '2026-08-18T12:00:00Z',
          'resolved_at': null
        },
      ];

  static List<Map<String, dynamic>> get onDemandJobs => [
        {
          'id': 861,
          'category': 1,
          'category_name': 'Electrical',
          'description': 'Need help fixing tripping breaker tonight',
          'status': 'matching',
          'address': 'Quezon City, Metro Manila',
          'budget': 1000.0,
          'created_at': '2026-08-25T12:00:00Z',
          'expires_at': '2026-08-25T14:00:00Z'
        },
        {
          'id': 862,
          'category': 3,
          'category_name': 'Cleaning',
          'description': 'Urgent cleanup after move-out this weekend',
          'status': 'accepted',
          'address': 'Pasig, Metro Manila',
          'budget': 2000.0,
          'created_at': '2026-08-24T09:00:00Z',
          'expires_at': '2026-08-26T09:00:00Z'
        },
      ];

  static List<Map<String, dynamic>> get sessionsList => [
        {
          'id': 'sess-demo-1',
          'device': 'Chrome on Windows',
          'location': 'Quezon City, PH',
          'last_active': '2026-08-25T13:50:00Z',
          'current': true,
          'created_at': '2026-08-01T08:00:00Z'
        },
        {
          'id': 'sess-demo-2',
          'device': 'Safari on iPhone',
          'location': 'Makati, PH',
          'last_active': '2026-08-24T20:12:00Z',
          'current': false,
          'created_at': '2026-08-10T07:45:00Z'
        },
      ];

  static Map<String, dynamic> get kycStatus => {
        'status': 'approved',
        'submitted_at': '2026-06-01T09:00:00Z',
        'reviewed_at': '2026-06-02T15:30:00Z',
        'rejection_reason': null,
        'submitter_role': 'provider',
        'id_verified': true,
        'face_verified': true,
        'nbi_verified': true,
      };

  static DemoReply resolve(RequestOptions options) {
    final method = options.method.toUpperCase();
    final path = options.uri.path;
    final query = options.queryParameters.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    final body =
        options.data is Map<String, dynamic> ? options.data as Map<String, dynamic> : <String, dynamic>{};

    return route(method, path, query, body);
  }

  static DemoReply paginated(
      List<Map<String, dynamic>> list, Map<String, dynamic> query) {
    final page = int.tryParse('${query['page'] ?? 1}') ?? 1;
    const pageSize = 20;
    final results = list.skip((page - 1) * pageSize).take(pageSize).toList();
    return DemoReply(200, {
      'count': list.length,
      'next': page * pageSize < list.length ? '?page=${page + 1}' : null,
      'previous': page > 1 ? '?page=${page - 1}' : null,
      'results': results,
    });
  }

  static DemoReply ok([Object? body]) => DemoReply(200, body ?? {});

  static DemoReply route(String method, String path,
      Map<String, dynamic> query, Map<String, dynamic> body) {
    RegExpMatch? m;

    // ---- Auth ----
    if (path == '/api/auth/login/' && method == 'POST') {
      final user = userForEmail('${body['email'] ?? ''}');
      currentRole = user['role'] as String;
      return ok(_tokenPayload(user));
    }
    if (path.startsWith('/api/auth/register/') && method == 'POST') {
      if (path.endsWith('/initiate/')) return ok({'delivery_method': 'email'});
      if (path.endsWith('/verify/')) {
        currentRole = 'client';
        return ok(_tokenPayload(clientUser));
      }
      return ok();
    }
    if (path.startsWith('/api/auth/otp/')) {
      if (path.endsWith('/verify-pin/') || path.endsWith('/verify/')) {
        return ok(_tokenPayload(currentUser));
      }
      return ok();
    }
    if (path == '/api/auth/phone-login/send/') return ok();
    if (path == '/api/auth/phone-login/verify/' && method == 'POST') {
      return ok(_tokenPayload(currentUser));
    }
    if (path == '/api/auth/me/') return ok(currentUser);
    if (path == '/api/auth/logout/') {
      currentRole = 'client';
      return ok();
    }
    if (path.startsWith('/api/auth/password-reset')) return ok();
    if (path == '/api/auth/sessions/' && method == 'POST') {
      return ok({
        'count': sessionsList.length,
        'results': sessionsList,
        'sessions': sessionsList,
      });
    }
    if (path.startsWith('/api/auth/sessions/')) return ok();
    if (path.startsWith('/api/auth/biometric/')) {
      if (path.endsWith('/credentials/')) return ok({'results': []});
      return ok({'status': 'ok', 'id': 'demo-credential'});
    }
    if (path == '/api/auth/me/skip-kyc/') {
      return ok({...currentUser, 'kyc_skipped': true});
    }

    if (path == '/api/auth/token/refresh/') {
      return ok({
        'access': 'demo-access-token',
        'refresh': 'demo-refresh-token',
        'session_id': 'demo-session',
      });
    }

    // ---- Users / profiles ----
    if (path == '/api/users/me/' && method == 'GET') {
      return ok({'profile': currentUser});
    }
    if (path == '/api/users/me/update/' && method == 'PATCH') {
      return ok({...currentUser, ...body});
    }
    if (path == '/api/users/me/photo/' && method == 'POST') {
      return ok({'photo_url': null});
    }
    if (path == '/api/users/me/delete/') return ok();
    m = RegExp(r'^/api/users/(\d+)/$').firstMatch(path);
    if (m != null && method == 'GET') {
      final provider = byId(providers, m.group(1));
      if (provider != null) return ok(provider);
      return ok({...currentUser, 'id': int.parse(m.group(1)!)});
    }

    // ---- Addresses ----
    if (path == '/api/profiles/addresses/' && method == 'GET') {
      return paginated(addresses, query);
    }
    if (path == '/api/profiles/addresses/' && method == 'POST') {
      return ok({...addresses.first, ...body, 'id': 89});
    }
    if (path.endsWith('/set-default/')) return ok();
    m = RegExp(r'^/api/profiles/addresses/(\d+)/$').firstMatch(path);
    if (m != null) {
      if (method == 'DELETE') return ok();
      final addr = byId(addresses, m.group(1)) ?? addresses.first;
      return ok(method == 'PATCH' ? {...addr, ...body} : addr);
    }

    // ---- Categories ----
    if (path == '/api/services/categories/') return paginated(categories, query);
    m = RegExp(r'^/api/services/categories/(\d+)/subcategories/$')
        .firstMatch(path);
    if (m != null) {
      return paginated(subcategoriesFor(int.parse(m.group(1)!)), query);
    }

    // ---- Listings ----
    if (path == '/api/services/listings/mine/') {
      return paginated(
          listings.where((l) => l['provider'] == 201).toList(), query);
    }
    if (path == '/api/services/listings/' && method == 'GET') {
      var list = listings;
      final search = '${query['search'] ?? ''}'.toLowerCase();
      final category = query['category'];
      if (search.isNotEmpty) {
        list = list
            .where((l) =>
                '${l['title']}'.toLowerCase().contains(search) ||
                '${l['category_name']}'.toLowerCase().contains(search))
            .toList();
      }
      if (category != null && category.isNotEmpty) {
        list = list.where((l) => '${l['category']}' == category).toList();
      }
      return paginated(list, query);
    }
    if (path == '/api/services/listings/' && method == 'POST') {
      final created = _listing(
          999,
          '${body['title'] ?? 'New Service'}',
          body['category'] as int? ?? 1,
          'General',
          201,
          'Maria Santos',
          (body['base_price'] as num?) ?? 500,
          '${body['price_unit'] ?? 'per visit'}',
          '0',
          0,
          'Quezon City');
      return DemoReply(201, created);
    }
    m = RegExp(r'^/api/services/listings/(\d+)/$').firstMatch(path);
    if (m != null) {
      if (method == 'DELETE') return ok();
      final listing = byId(listings, m.group(1)) ?? listings.first;
      return ok(method == 'PATCH' ? {...listing, ...body} : listing);
    }
    if (path.endsWith('/archive/') || path.endsWith('/unarchive/')) {
      return ok({'status': 'active'});
    }
    if (path.endsWith('/upload-thumbnail/')) return ok({'thumbnail': null});

    // ---- Reviews ----
    m = RegExp(r'^/api/services/listings/(\d+)/reviews/$').firstMatch(path);
    if (m != null && method == 'GET') {
      return paginated(
          reviews.where((rv) => '${rv['listing']}' == m!.group(1)).toList(),
          query);
    }
    if (path == '/api/services/reviews/mine/') return ok(reviews);
    m = RegExp(r'^/api/services/bookings/(\d+)/review/$').firstMatch(path);
    if (m != null && method == 'POST') {
      return ok({
        'id': 99,
        'booking': int.parse(m.group(1)!),
        'rating': body['rating'],
        'comment': body['comment'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // ---- Favorites (bare-list responses) ----
    if (path == '/api/favorites/' && method == 'POST') {
      return ok({'favorited': true});
    }
    m = RegExp(r'^/api/favorites/(\d+)/$').firstMatch(path);
    if (m != null && method == 'DELETE') return ok();
    if (path == '/api/favorites/list/') return ok([listings[2], listings[4]]);

    // ---- Bids ----
    if (path == '/api/services/bids/' && method == 'GET') {
      return paginated([], query);
    }
    if (path == '/api/services/bids/' && method == 'POST') {
      return ok({'id': 95, 'status': 'submitted', ...body});
    }
    if (path.endsWith('/withdraw/')) return ok();

    // ---- Bookings ----
    if ((path == '/api/services/bookings/' ||
            path == '/api/services/bookings/list/') &&
        method == 'GET') {
      return paginated(bookings, query);
    }
    if (path == '/api/services/bookings/' && method == 'POST') {
      final listingId = body['listing'] as int? ?? 1;
      final listing = byId(listings, '$listingId') ?? listings.first;
      final created = _booking(
        ++_nextBookingId,
        listingId,
        'pending',
        '${listing['provider_name']}',
        '${body['scheduled_date'] ?? '2026-09-01'}',
        '${body['scheduled_time'] ?? '09:00:00'}',
        (listing['base_price'] as num?) ?? 500,
        null,
        'Quezon City',
        notes: body['notes'] as String?,
      );
      bookings = [created, ...bookings];
      return DemoReply(201, created);
    }
    m = RegExp(r'^/api/services/bookings/(\d+)/$').firstMatch(path);
    if (m != null) {
      final booking = byId(bookings, m.group(1)) ?? bookings.first;
      return method == 'PATCH' ? ok({...booking, ...body}) : ok(booking);
    }
    m = RegExp(
            r'^/api/services/bookings/(\d+)/(accept|reject|confirm-arrival|start|complete|upload-photo|parts-cost)/$')
        .firstMatch(path);
    if (m != null) {
      final action = m.group(2)!;
      final booking = byId(bookings, m.group(1)) ?? bookings.first;
      final updated = Map<String, dynamic>.from(booking);
      switch (action) {
        case 'accept':
          updated['status'] = 'confirmed';
        case 'reject':
          updated['status'] = 'rejected';
        case 'confirm-arrival':
          updated['status'] = 'arrived';
          updated['arrived_at'] = DateTime.now().toIso8601String();
        case 'start':
          updated['status'] = 'in_progress';
          updated['started_at'] = DateTime.now().toIso8601String();
        case 'complete':
          updated['status'] = 'completed';
          updated['completed_at'] = DateTime.now().toIso8601String();
        case 'parts-cost':
          final cost = (body['cost'] as num?) ?? 0;
          updated['parts_cost'] = cost.toDouble();
          updated['total_price'] = ((updated['total_price'] as num?) ?? 0) + cost;
      }
      bookings = [
        for (final b in bookings)
          if (b['id'] == updated['id']) updated else b
      ];
      return ok(updated);
    }

    // ---- Availability ----
    if (path == '/api/services/availability/') {
      return ok({'results': availabilitySlots});
    }
    if (path == '/api/services/availability/slots/' && method == 'GET') {
      return ok({'results': availabilitySlots});
    }
    if (path == '/api/services/availability/slots/' && method == 'POST') {
      return ok({'id': 404, 'is_available': true, ...body});
    }
    if (path.startsWith('/api/services/availability/slots/')) return ok();

    // ---- Chat ----
    if (path == '/api/chat/threads/') return paginated(threads, query);
    m = RegExp(r'^/api/chat/threads/(\d+)/$').firstMatch(path);
    if (m != null && method == 'GET') {
      return ok(byId(threads, m.group(1)) ?? threads.first);
    }
    m = RegExp(r'^/api/chat/threads/(\d+)/messages/$').firstMatch(path);
    if (m != null) {
      return paginated(messagesFor(int.parse(m.group(1)!)), query);
    }
    m = RegExp(r'^/api/chat/threads/(\d+)/send/$').firstMatch(path);
    if (m != null) {
      return ok({
        'id': 999,
        'thread': int.parse(m.group(1)!),
        'content': body['content'],
        'sender_id': currentUser['id'],
        'sender_name': currentUser['display_name'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    if (path.endsWith('/read/')) return ok();
    if (path == '/api/chat/calls/initiate/') {
      return ok({
        'call_id': 'demo-call',
        'token': 'demo-call-token',
        'room': 'demo-room',
      });
    }
    m = RegExp(r'^/api/chat/threads/booking/(\d+)/$').firstMatch(path);
    if (m != null) return ok(threads.first);

    // ---- Notifications (bare list) ----
    if (path == '/api/notifications/' && method == 'GET') {
      return ok(notifications);
    }
    m = RegExp(r'^/api/notifications/(\d+)/read/$').firstMatch(path);
    if (m != null) {
      for (final n in notifications) {
        if ('${n['id']}' == m!.group(1)) n['is_read'] = true;
      }
      return ok();
    }
    if (path == '/api/notifications/mark-all-read/') {
      for (final n in notifications) {
        n['is_read'] = true;
      }
      return ok();
    }
    if (path == '/api/notifications/preferences/') {
      return ok({
        'push_enabled': true,
        'email_enabled': true,
        'sms_enabled': false,
        'booking_updates': true,
        'messages': true,
        'promotions': false,
      });
    }
    if (path == '/api/notifications/preferences/update/') return ok(body);

    // ---- Projects ----
    if (path == '/api/projects/list/') return paginated(projects, query);
    if (path == '/api/projects/' && method == 'POST') {
      return DemoReply(201, {'id': 703, 'status': 'open', ...body});
    }
    m = RegExp(r'^/api/projects/(\d+)/$').firstMatch(path);
    if (m != null) {
      final project = byId(projects, m.group(1)) ?? projects.first;
      return method == 'GET' ? ok(project) : ok({...project, ...body});
    }
    if (path.endsWith('/quote/')) {
      return ok({'id': 96, 'amount': body['amount'], 'status': 'quoted'});
    }
    if (path.endsWith('/match/')) {
      return ok({'matched': true, 'provider': providers.first});
    }
    if (path.endsWith('/cancel/')) return ok({'status': 'cancelled'});

    // ---- Rooms ----
    if (path == '/api/services/rooms/list/') return paginated(rooms, query);
    if (path == '/api/services/rooms/' && method == 'POST') {
      return DemoReply(201, {
        'id': ++_nextRoomId,
        'name': body['name'],
        'join_token': 'demo-room-new',
        'is_locked': false,
        'members_count': 1,
      });
    }
    m = RegExp(r'^/api/services/rooms/(\d+)/$').firstMatch(path);
    if (m != null) {
      return ok(byId(rooms, m.group(1)) ?? rooms.first);
    }
    if (path.endsWith('/join/')) return ok({...rooms.first, 'joined': true});
    if (path.endsWith('/leave/') ||
        path.endsWith('/lock/') ||
        path.endsWith('/cancel/')) {
      return ok();
    }
    m = RegExp(r'^/api/services/rooms/by-token/(.+?)/$').firstMatch(path);
    if (m != null) return ok(rooms.first);

    // ---- Disputes ----
    if (path == '/api/disputes/list/') return paginated(disputes, query);
    if (path == '/api/disputes/' && method == 'POST') {
      return DemoReply(201, {'id': 852, 'status': 'open', ...body});
    }
    m = RegExp(r'^/api/disputes/(\d+)/$').firstMatch(path);
    if (m != null) {
      return ok(byId(disputes, m.group(1)) ?? disputes.first);
    }
    m = RegExp(r'^/api/disputes/booking/(\d+)/$').firstMatch(path);
    if (m != null) return ok(disputes.first);

    // ---- On-demand jobs ----
    if (path == '/api/services/on-demand/client/jobs/') {
      return paginated(onDemandJobs, query);
    }
    if (path == '/api/services/on-demand/' && method == 'POST') {
      return DemoReply(201, {'id': 863, 'status': 'matching', ...body});
    }
    m = RegExp(r'^/api/services/on-demand/(\d+)/$').firstMatch(path);
    if (m != null) {
      return ok(byId(onDemandJobs, m.group(1)) ?? onDemandJobs.first);
    }
    if (path.endsWith('/cancel/')) return ok({'status': 'cancelled'});

    // ---- Tracking / ETA ----
    m = RegExp(r'^/api/services/eta/(.+?)/$').firstMatch(path);
    if (m != null && method == 'GET') {
      return ok({
        'eta_minutes': 12,
        'distance_km': 2.4,
        'provider_lat': 14.63,
        'provider_lng': 121.03,
        'status': 'en_route',
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    // ---- Earnings / analytics ----
    if (path == '/api/earnings/summary/') return ok(earningsSummary);
    if (path == '/api/earnings/transactions/') {
      return paginated(earningsTransactions, query);
    }
    if (path == '/api/earnings/payouts/') return paginated(payouts, query);
    if (path == '/api/earnings/request-payout/') {
      return ok({'status': 'processing', 'amount': body['amount']});
    }
    if (path == '/api/analytics/provider/') return ok(providerAnalytics);
    if (path == '/api/analytics/revenue-breakdown/') {
      return ok({
        'categories': categories
            .take(4)
            .map((c) => {'label': c['name'], 'value': 4200.0})
            .toList(),
      });
    }
    m = RegExp(r'^/api/analytics/services/(\d+)/metrics/$').firstMatch(path);
    if (m != null) {
      return ok({
        'views': 320,
        'bookings': 18,
        'conversion_rate': 0.28,
        'avg_rating': 4.7,
      });
    }

    // ---- KYC ----
    if (path == '/api/kyc/status/') return ok(kycStatus);
    if (path == '/api/kyc/liveness/challenge/') {
      return ok({
        'nonce': 'demo-nonce-123',
        'plan': [],
        'expiresAt':
            DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
      });
    }
    if (path == '/api/kyc/submit/') {
      return ok({'status': 'submitted', ...kycStatus});
    }

    // ---- Support ----
    if (path == '/api/support/tickets/') {
      return DemoReply(201, {'id': 97, 'status': 'open', ...body});
    }

    if (method == 'GET') return paginated([], query);
    return ok();
  }

  static Map<String, dynamic> _tokenPayload(Map<String, dynamic> user) {
    return {
      'user': user,
      'access': 'demo-access-token',
      'refresh': 'demo-refresh-token',
      'session_id': 'demo-session',
      'token': 'demo-access-token',
    };
  }
}
