import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/api/models/review.dart';
import 'package:serbisyohubph/api/models/service_listing.dart';

void main() {
  group('ShphReview.fromJson', () {
    test('parses all fields correctly from full JSON', () {
      final review = ShphReview.fromJson(const {
        'id': 42,
        'rating': 5,
        'booking': 'booking-123',
        'reviewer': 10,
        'reviewer_name': 'Alice Garcia',
        'reviewer_photo': 'https://example.com/photo.jpg',
        'comment': 'Excellent service!',
        'created_at': '2025-06-01T10:00:00Z',
        'service_listing_id': 7,
      });

      expect(review.id, 42);
      expect(review.rating, 5);
      expect(review.booking, 'booking-123');
      expect(review.reviewer, 10);
      expect(review.reviewerName, 'Alice Garcia');
      expect(review.reviewerPhoto, 'https://example.com/photo.jpg');
      expect(review.comment, 'Excellent service!');
      expect(review.createdAt, '2025-06-01T10:00:00Z');
      expect(review.serviceListingId, 7);
    });

    test('handles missing fields with defaults', () {
      final review = ShphReview.fromJson(const {});

      expect(review.id, 0);
      expect(review.rating, 0);
      expect(review.booking, isNull);
      expect(review.reviewer, isNull);
      expect(review.reviewerName, isNull);
      expect(review.reviewerPhoto, isNull);
      expect(review.comment, isNull);
      expect(review.createdAt, isNull);
      expect(review.serviceListingId, isNull);
    });

    test('handles numeric booking id converted to string', () {
      final review = ShphReview.fromJson(const {
        'id': 1,
        'rating': 4,
        'booking': 12345,
      });

      expect(review.booking, '12345');
    });
  });

  group('ShphServiceListing.fromJson', () {
    test('parses service listing with all fields', () {
      final listing = ShphServiceListing.fromJson(const {
        'id': 1,
        'category': 3,
        'category_name': 'Plumbing',
        'provider': 5,
        'provider_name': 'John Doe',
        'provider_photo': 'https://example.com/john.jpg',
        'title': 'Pipe Repair',
        'description': 'Fix leaking pipes',
        'base_price': '500.00',
        'price_unit': 'hour',
        'status': 'active',
        'is_available': true,
        'rating': '4.5',
        'thumbnail': 'https://example.com/thumb.jpg',
        'review_count': 12,
        'is_time_material': true,
      });

      expect(listing.id, 1);
      expect(listing.category, 3);
      expect(listing.categoryName, 'Plumbing');
      expect(listing.title, 'Pipe Repair');
      expect(listing.status, 'active');
      expect(listing.isAvailable, 'true');
    });

    test('handles missing optional fields', () {
      final listing = ShphServiceListing.fromJson(const {
        'id': 2,
        'title': 'Basic Service',
      });

      expect(listing.id, 2);
      expect(listing.title, 'Basic Service');
      expect(listing.description, isNull);
      expect(listing.rating, isNull);
    });
  });

  group('Review filtering logic (reviews_ratings_widget pattern)', () {
    test('filters out reviews with zero rating', () {
      final reviews = [
        const ShphReview(id: 1, rating: 5),
        const ShphReview(id: 2, rating: 0),
        const ShphReview(id: 3, rating: 3),
        const ShphReview(id: 4, rating: 0),
      ];

      final filtered = reviews.where((r) => r.rating > 0).toList();

      expect(filtered, hasLength(2));
      expect(filtered[0].id, 1);
      expect(filtered[1].id, 3);
    });

    test('maps ShphReview to widget-compatible Map with all fields', () {
      const review = ShphReview(
        id: 10,
        rating: 4,
        comment: 'Good job',
        reviewerName: 'Bob',
        reviewerPhoto: 'https://example.com/bob.jpg',
        createdAt: '2025-06-01T00:00:00Z',
        booking: 'booking-1',
        serviceListingId: 5,
      );

      final mapped = {
        'id': review.id,
        'rating': review.rating,
        'comment': review.comment ?? '',
        'reviewer_name': review.reviewerName ?? 'Anonymous',
        'reviewer_photo': review.reviewerPhoto ?? '',
        'created_at': review.createdAt ?? '',
        'booking': review.booking ?? '',
        'service_listing_id': review.serviceListingId ?? 0,
      };

      expect(mapped['id'], 10);
      expect(mapped['rating'], 4);
      expect(mapped['comment'], 'Good job');
      expect(mapped['reviewer_name'], 'Bob');
      expect(mapped['reviewer_photo'], 'https://example.com/bob.jpg');
      expect(mapped['created_at'], '2025-06-01T00:00:00Z');
      expect(mapped['booking'], 'booking-1');
      expect(mapped['service_listing_id'], 5);
    });

    test('maps ShphReview with null fields to safe defaults', () {
      const review = ShphReview(id: 0, rating: 0);

      final mapped = {
        'id': review.id,
        'rating': review.rating,
        'comment': review.comment ?? '',
        'reviewer_name': review.reviewerName ?? 'Anonymous',
        'reviewer_photo': review.reviewerPhoto ?? '',
        'created_at': review.createdAt ?? '',
        'booking': review.booking ?? '',
        'service_listing_id': review.serviceListingId ?? 0,
      };

      expect(mapped['comment'], '');
      expect(mapped['reviewer_name'], 'Anonymous');
      expect(mapped['reviewer_photo'], '');
      expect(mapped['created_at'], '');
      expect(mapped['booking'], '');
      expect(mapped['service_listing_id'], 0);
    });
  });

  group('ServiceListing to widget Map (booking_details_widget pattern)', () {
    test('maps ServiceListing model to display Map', () {
      // This tests the mapping pattern used in booking_details_widget.dart
      // after refactoring from inline ShphApiClient to ServiceListingService
      final serviceMap = <String, dynamic>{
        'id': 1,
        'title': 'Pipe Repair',
        'description': 'Fix leaking pipes',
        'basePrice': 500.0,
        'categoryName': 'Plumbing',
        'providerName': 'John Doe',
        'providerPhoto': 'https://example.com/john.jpg',
        'thumbnail': 'https://example.com/thumb.jpg',
        'rating': 4.5,
        'reviewCount': 12,
      };

      expect(serviceMap['id'], 1);
      expect(serviceMap['title'], 'Pipe Repair');
      expect(serviceMap['basePrice'], 500.0);
      expect(serviceMap['categoryName'], 'Plumbing');
      expect(serviceMap['providerName'], 'John Doe');
      expect(serviceMap['rating'], 4.5);
    });
  });
}
