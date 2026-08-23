import '/api/api_config.dart';
import '/api/models/address.dart';
import '/api/models/booking.dart';
import '/api/models/category.dart';
import '/api/models/review.dart';
import '/api/models/service_listing.dart';
import '/api/shph_token_storage.dart';
import '/backend/supabase/database/tables/addresses.dart';
import '/backend/supabase/database/tables/bookings.dart';
import '/backend/supabase/database/tables/categories.dart';
import '/backend/supabase/database/tables/profiles.dart';
import '/backend/supabase/database/tables/reviews.dart';
import '/backend/supabase/database/tables/service_listings.dart';

/// Maps SHPH API models to existing Supabase row types so UI code stays stable.
class ApiRowMapper {
  ApiRowMapper._();

  static Future<bool> canUseApi() async {
    if (!ApiConfig.preferShphApi) return false;
    return ShphTokenStorage.hasAccessToken();
  }

  static String normalizeBookingStatus(String status) {
    switch (status) {
      case 'confirmed':
        return 'accepted';
      case 'en_route':
        return 'in_progress';
      default:
        return status;
    }
  }

  static BookingsRow bookingToRow(ShphBooking booking) {
    DateTime bookingDate = DateTime.now();
    if (booking.scheduledDate != null) {
      bookingDate = DateTime.tryParse(booking.scheduledDate!) ?? bookingDate;
    } else if (booking.scheduledAt != null) {
      bookingDate = DateTime.tryParse(booking.scheduledAt!) ?? bookingDate;
    }

    final data = <String, dynamic>{
      'id': booking.id,
      'user_id': booking.clientId?.toString() ?? '',
      'service_listing_id': booking.listing,
      'provider_id': booking.providerId?.toString(),
      'booking_date': bookingDate.toIso8601String(),
      'booking_time': booking.scheduledTime ?? '00:00:00',
      'notes': booking.notes,
      'status': normalizeBookingStatus(booking.status),
      'total_price': booking.totalPrice ?? booking.agreedPrice,
      'created_at': booking.createdAt ?? DateTime.now().toIso8601String(),
    };

    if (booking.serviceListing != null) {
      data['service_listings'] = booking.serviceListing;
    }
    if (booking.clientProfile != null) {
      data['profiles'] = booking.clientProfile;
    }
    if (booking.clientAddress != null) {
      data['client_address'] = booking.clientAddress;
    }
    if (booking.arrivedAt != null) {
      data['arrived_at'] = booking.arrivedAt;
    }
    if (booking.startedAt != null) {
      data['started_at'] = booking.startedAt;
    }

    return BookingsRow(data);
  }

  static ServiceListingsRow serviceListingToRow(ShphServiceListing listing) {
    return ServiceListingsRow({
      'id': listing.id,
      'category': listing.category,
      'category_name': listing.categoryName,
      'provider': listing.provider,
      'provider_name': listing.providerName,
      'provider_photo': listing.providerPhoto,
      'title': listing.title,
      'description': listing.description,
      'base_price': listing.basePrice,
      'price_unit': listing.priceUnit,
      'status': listing.status,
      'is_available': listing.isAvailable ?? 'true',
      'rating': listing.rating,
      'thumbnail': listing.thumbnail,
      'review_count': listing.reviewCount ?? 0,
      'is_time_material': listing.isTimeMaterial,
      'created_at': listing.createdAt ?? DateTime.now().toIso8601String(),
      'latitude': listing.latitude,
      'longitude': listing.longitude,
      'distance_km': listing.distanceKm,
    });
  }

  static CategoriesRow categoryToRow(ShphCategory category) {
    return CategoriesRow({
      'id': category.id,
      'name': category.name,
      'description': category.description,
      'icon': category.icon,
      'image_url': category.image,
      'sort_order': category.id,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static AddressesRow addressToRow(ShphAddress address) {
    return AddressesRow({
      'id': address.id,
      'user_id': '',
      'address_line1': address.street,
      'address_line2': address.label,
      'barangay': address.barangay,
      'city': address.city,
      'province': address.province,
      'postal_code': address.zipCode,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'is_default': address.isDefault,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static ReviewsRow reviewToRow(
    ShphReview review, {
    int? serviceListingId,
  }) {
    return ReviewsRow({
      'id': review.id.toString(),
      'user_id': review.reviewer?.toString() ?? '',
      'service_listing_id': serviceListingId ?? review.serviceListingId ?? 0,
      'rating': review.rating,
      'comment': review.comment,
      'created_at': review.createdAt ?? DateTime.now().toIso8601String(),
      if (review.reviewerName != null)
        'profiles': {
          'display_name': review.reviewerName,
          'photo_url': review.reviewerPhoto,
        },
    });
  }

  static ProfilesRow profileToRow(Map<String, dynamic> data) {
    return ProfilesRow({
      'id': data['id']?.toString() ?? '',
      'role': data['role']?.toString() ?? 'client',
      'display_name': data['display_name'],
      'email': data['email'],
      'phone_number': data['phone_number'] ?? data['phone'],
      'photo_url': data['photo_url'] ?? data['photo'],
      'face_scan_url': data['face_scan_url'] ?? data['photo_url'] ?? data['photo'],
      'bio_details': data['bio_details'] ?? data['bio'],
      'first_name': data['first_name'],
      'last_name': data['last_name'],
      'verification_status': data['verification_status'] ?? 'pending',
      'is_profile_complete': data['is_profile_complete'] ?? false,
      'is_verified': data['is_verified'] ?? false,
      'is_face_verified': data['is_face_verified'] ?? false,
      'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at': data['updated_at'] ?? DateTime.now().toIso8601String(),
    });
  }
}
