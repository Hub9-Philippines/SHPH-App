import '/api/api_config.dart';
import '/api/shph_api_client.dart';
import '/services/logging_service.dart';

export 'api_config.dart';
export 'bridges/api_row_mapper.dart';
export 'bridges/shph_auth_bridge.dart';
export 'models/booking.dart';
export 'models/category.dart';
export 'models/paginated_response.dart';
export 'models/project.dart';
export 'models/review.dart';
export 'models/room.dart';
export 'models/service_listing.dart';
export 'models/session.dart';
export 'models/support_ticket.dart';
export 'resources/auth_api.dart';
export 'resources/bookings_api.dart';
export 'resources/chat_api.dart';
export 'resources/favorites_api.dart';
export 'resources/kyc_api.dart';
export 'resources/projects_api.dart';
export 'resources/rooms_api.dart';
export 'resources/services_api.dart';
export 'resources/support_api.dart';
export 'resources/users_api.dart';
export 'shph_api_client.dart';
export 'shph_api_exception.dart';
export 'shph_token_storage.dart';

/// Initializes the SHPH REST API client layer.
Future<void> initializeShphApi() async {
  if (!ApiConfig.isConfigured) {
    LoggingService.debug(
      'SHPH API base URL not configured; skipping client init',
      tag: 'ShphApi',
    );
    return;
  }

  await ShphApiClient.initialize();
  LoggingService.info(
    'SHPH API client ready (base=${ApiConfig.baseUrl})',
    tag: 'ShphApi',
  );
}
