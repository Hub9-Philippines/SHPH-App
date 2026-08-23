import '/api/models/service_listing.dart';
import '/api/resources/services_api.dart';
import '/services/logging_service.dart';

class MyServicesService {
  MyServicesService._();
  static final MyServicesService instance = MyServicesService._();

  final _servicesApi = ShphServicesApi.instance;

  Future<List<ShphServiceListing>> getMyListings({int? page}) async {
    try {
      final result = await _servicesApi.listMyListings(page: page);
      return result.results;
    } catch (e) {
      LoggingService.error('Failed to fetch my listings: $e',
          tag: 'MyServicesService');
      return [];
    }
  }

  Future<ShphServiceListing?> updateListing(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _servicesApi.updateListing(id, payload);
    } catch (e) {
      LoggingService.error('Failed to update listing: $e',
          tag: 'MyServicesService');
      return null;
    }
  }

  Future<bool> deleteListing(int id) async {
    try {
      await _servicesApi.deleteListing(id);
      return true;
    } catch (e) {
      LoggingService.error('Failed to delete listing: $e',
          tag: 'MyServicesService');
      return false;
    }
  }

  Future<bool> archiveListing(int id) async {
    try {
      await _servicesApi.archiveListing(id);
      return true;
    } catch (e) {
      LoggingService.error('Failed to archive listing: $e',
          tag: 'MyServicesService');
      return false;
    }
  }

  Future<bool> unarchiveListing(int id) async {
    try {
      await _servicesApi.unarchiveListing(id);
      return true;
    } catch (e) {
      LoggingService.error('Failed to unarchive listing: $e',
          tag: 'MyServicesService');
      return false;
    }
  }
}
