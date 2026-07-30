import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/my_services_service.dart';
import 'my_services_widget.dart' show MyServicesWidget;

class MyServicesModel extends FlutterFlowModel<MyServicesWidget> {
  List<Map<String, dynamic>> listings = [];
  bool isLoading = true;
  String? fetchError;

  @override
  void initState(BuildContext context) {}

  Future<void> loadListings() async {
    isLoading = true;
    fetchError = null;
    try {
      final results = await MyServicesService.instance.getMyListings();
      listings = results.map((l) => l.toJson()).toList();
    } catch (e) {
      fetchError = 'Failed to load services.';
    } finally {
      isLoading = false;
    }
  }

  Future<bool> toggleAvailability(int index, bool available) async {
    final listing = listings[index];
    final id = listing['id'] as int?;
    if (id == null) return false;
    listings[index] = {...listing, 'is_available': available};
    final updated = await MyServicesService.instance
        .updateListing(id, {'is_available': available});
    if (updated == null) {
      listings[index] = {...listing, 'is_available': !available};
      return false;
    }
    listings[index] = updated.toJson();
    return true;
  }

  Future<bool> toggleArchive(int index) async {
    final listing = listings[index];
    final id = listing['id'] as int?;
    if (id == null) return false;
    final isArchived = listing['status'] == 'archived';
    final ok = isArchived
        ? await MyServicesService.instance.unarchiveListing(id)
        : await MyServicesService.instance.archiveListing(id);
    if (ok) {
      final updated = await MyServicesService.instance.getMyListings();
      listings = updated.map((l) => l.toJson()).toList();
    }
    return ok;
  }

  Future<bool> deleteListing(int index) async {
    final listing = listings[index];
    final id = listing['id'] as int?;
    if (id == null) return false;
    final ok = await MyServicesService.instance.deleteListing(id);
    if (ok) listings.removeAt(index);
    return ok;
  }

  @override
  void dispose() {}
}
