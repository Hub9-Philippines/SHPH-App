import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '/app_state.dart';
import '/models/service_listing.dart';
import '/pages/dispatch/dispatch_repository.dart';
import '/services/logging_service.dart';
import '/utils/geo_utils.dart';

import 'tm_catalog.dart';
import 'tm_models.dart';
import 'tm_repository.dart';

enum TMBroadcastStage { idle, nearbySearch, expandedSearch, failed }

class TMFlowController extends ChangeNotifier {
  TMFlowController({required this.selectedService, TMRepository? repository})
      : repository = repository ?? _createDispatchRepository(),
        _subCategories = tmSubCategoriesForService(selectedService);

  static DispatchTMRepository _createDispatchRepository() {
    final appState = FFAppState();
    final lat = appState.selectedLatitude;
    final lng = appState.selectedLongitude;
    return DispatchTMRepository(
      clientLatitude:
          GeoUtils.hasValidLocation(lat, lng) ? lat! : GeoUtils.fallbackLat,
      clientLongitude:
          GeoUtils.hasValidLocation(lat, lng) ? lng! : GeoUtils.fallbackLng,
    );
  }

  final ServiceListing selectedService;
  final TMRepository repository;
  final List<TMSubCategoryOption> _subCategories;
  final StreamController<TMHardwareRequest> _hardwareRequestController =
      StreamController<TMHardwareRequest>.broadcast();

  TMSubCategoryOption? _selectedSubCategory;
  Ticker? _ticker;
  StreamSubscription<TMBookingSnapshot?>? _snapshotSubscription;
  int _secondsRemaining = 60;
  int _searchRadiusKm = 4;
  int _searchAttempt = 1;
  int _searchCycleId = 0;
  int _activeJobCycleId = 0;
  TMBroadcastStage _broadcastStage = TMBroadcastStage.idle;
  String? _broadcastNotice;
  String? _searchReferenceId;
  String? _dispatchMode;
  TMProviderProfile? _matchedProvider;
  TMHardwareRequest? _pendingHardwareRequest;
  String? _lastHardwareRequestId;
  double _approvedHardwareCost = 0;
  bool _jobCompleted = false;
  bool _isCancellingBroadcast = false;
  bool _isUpdatingHardware = false;
  bool _isCompletingJob = false;
  bool _isProcessingPayment = false;
  bool _isSubmittingRating = false;
  int _submittedRating = 0;
  String _paymentMethod = 'GCash';
  String? _lastErrorMessage;

  List<TMSubCategoryOption> get subCategories =>
      List.unmodifiable(_subCategories);

  TMSubCategoryOption? get selectedSubCategory => _selectedSubCategory;

  String get selectedServiceLabel => selectedService.title;

  int get secondsRemaining => _secondsRemaining;

  int get searchRadiusKm => _searchRadiusKm;

  TMBroadcastStage get broadcastStage => _broadcastStage;

  String? get broadcastNotice => _broadcastNotice;

  String? get searchReferenceId => _searchReferenceId;

  String? get dispatchMode => _dispatchMode;

  bool get isServerDispatchMode => _dispatchMode == 'server';

  bool get isFallbackDispatchMode => _dispatchMode == 'fallback';

  TMProviderProfile? get matchedProvider => _matchedProvider;

  Stream<TMHardwareRequest> get hardwareRequests =>
      _hardwareRequestController.stream;

  TMHardwareRequest? get pendingHardwareRequest => _pendingHardwareRequest;

  double get approvedHardwareCost => _approvedHardwareCost;

  bool get jobCompleted => _jobCompleted;

  bool get isCancellingBroadcast => _isCancellingBroadcast;

  bool get isUpdatingHardware => _isUpdatingHardware;

  bool get isCompletingJob => _isCompletingJob;

  bool get isProcessingPayment => _isProcessingPayment;

  bool get isSubmittingRating => _isSubmittingRating;

  int get submittedRating => _submittedRating;

  String get paymentMethod => _paymentMethod;

  String? get lastErrorMessage => _lastErrorMessage;

  bool get isSearching =>
      _broadcastStage == TMBroadcastStage.nearbySearch ||
      _broadcastStage == TMBroadcastStage.expandedSearch;

  bool get hasFailed => _broadcastStage == TMBroadcastStage.failed;

  bool get hasMatchedProvider => _matchedProvider != null;

  double get baseLaborCost {
    final option = _selectedSubCategory;
    if (option == null) {
      return selectedService.basePrice ?? 500;
    }
    return (option.estimateMin + option.estimateMax) / 2;
  }

  double get totalInvoiceAmount => baseLaborCost + _approvedHardwareCost;

  void selectSubCategory(TMSubCategoryOption option) {
    _selectedSubCategory = option;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearLastError() {
    if (_lastErrorMessage == null) {
      return;
    }
    _lastErrorMessage = null;
  }

  void startBroadcast() {
    final option = _selectedSubCategory;
    if (option == null) {
      return;
    }

    final appState = FFAppState();
    if (!GeoUtils.hasValidLocation(
        appState.selectedLatitude, appState.selectedLongitude)) {
      LoggingService.debug(
        'No valid pinned location for broadcast — search will use Manila fallback',
        tag: 'TMFlowController',
      );
    }

    _searchCycleId++;
    _activeJobCycleId++;
    _ticker?.dispose();
    _snapshotSubscription?.cancel();
    _snapshotSubscription = null;
    _secondsRemaining = 60;
    _searchRadiusKm = 4;
    _searchAttempt = 1;
    _broadcastStage = TMBroadcastStage.nearbySearch;
    _broadcastNotice = null;
    _searchReferenceId = null;
    _dispatchMode = null;
    _matchedProvider = null;
    _pendingHardwareRequest = null;
    _lastHardwareRequestId = null;
    _approvedHardwareCost = 0;
    _jobCompleted = false;
    _isCancellingBroadcast = false;
    _isUpdatingHardware = false;
    _isCompletingJob = false;
    _isProcessingPayment = false;
    _isSubmittingRating = false;
    _submittedRating = 0;
    _lastErrorMessage = null;
    _startTicker();
    unawaited(_startRepositorySearch(option, cycleId: _searchCycleId));
    notifyListeners();
  }

  void retryBroadcast() {
    startBroadcast();
  }

  void clearBroadcastNotice() {
    if (_broadcastNotice == null) {
      return;
    }
    _broadcastNotice = null;
  }

  void cancelBroadcast() {
    _searchCycleId++;
    _activeJobCycleId++;
    _ticker?.dispose();
    _ticker = null;
    _snapshotSubscription?.cancel();
    _snapshotSubscription = null;
    _broadcastStage = TMBroadcastStage.idle;
    _secondsRemaining = 60;
    _searchRadiusKm = 4;
    _searchAttempt = 1;
    _searchReferenceId = null;
    _dispatchMode = null;
    _broadcastNotice = null;
    _matchedProvider = null;
    _pendingHardwareRequest = null;
    _lastHardwareRequestId = null;
    _approvedHardwareCost = 0;
    _jobCompleted = false;
    _isCancellingBroadcast = false;
    _isUpdatingHardware = false;
    _isCompletingJob = false;
    _isProcessingPayment = false;
    _isSubmittingRating = false;
    _submittedRating = 0;
    notifyListeners();
  }

  void beginActiveJob() {
    if (_jobCompleted ||
        _pendingHardwareRequest != null ||
        !hasMatchedProvider) {
      return;
    }
    final option = _selectedSubCategory;
    final provider = _matchedProvider;
    if (option == null || provider == null) {
      return;
    }

    final cycleId = ++_activeJobCycleId;
    unawaited(_requestHardwareIfNeeded(option, provider, cycleId: cycleId));
  }

  void emitHardwareRequest(TMHardwareRequest request) {
    _pendingHardwareRequest = request;
    _hardwareRequestController.add(request);
    notifyListeners();
  }

  Future<bool> approveHardwareRequest() async {
    final request = _pendingHardwareRequest;
    final requestId = _searchReferenceId;
    final option = _selectedSubCategory;
    if (request == null || requestId == null || option == null) {
      return false;
    }
    if (_isUpdatingHardware) {
      return false;
    }
    _isUpdatingHardware = true;
    notifyListeners();
    final approvedTotal =
        baseLaborCost + _approvedHardwareCost + request.additionalCost;
    try {
      final success = await repository.updateHardwareApproval(
        requestId: requestId,
        service: selectedService,
        subCategory: option,
        request: request,
        approved: true,
        totalPrice: approvedTotal,
      );
      if (!success) {
        _lastErrorMessage = 'Could not approve the hardware request right now.';
        return false;
      }
      _approvedHardwareCost += request.additionalCost;
      _lastHardwareRequestId = request.id;
      _pendingHardwareRequest = null;
      return true;
    } finally {
      _isUpdatingHardware = false;
      notifyListeners();
    }
  }

  Future<bool> rejectHardwareRequest() async {
    final request = _pendingHardwareRequest;
    final requestId = _searchReferenceId;
    final option = _selectedSubCategory;
    if (request == null || requestId == null || option == null) {
      return false;
    }
    if (_isUpdatingHardware) {
      return false;
    }
    _isUpdatingHardware = true;
    notifyListeners();
    try {
      final success = await repository.updateHardwareApproval(
        requestId: requestId,
        service: selectedService,
        subCategory: option,
        request: request,
        approved: false,
        totalPrice: baseLaborCost + _approvedHardwareCost,
      );
      if (!success) {
        _lastErrorMessage = 'Could not reject the hardware request right now.';
        return false;
      }
      _lastHardwareRequestId = request.id;
      _pendingHardwareRequest = null;
      return true;
    } finally {
      _isUpdatingHardware = false;
      notifyListeners();
    }
  }

  Future<bool> completeJob() async {
    final requestId = _searchReferenceId;
    final option = _selectedSubCategory;
    if (requestId == null || option == null || _isCompletingJob) {
      return false;
    }
    _isCompletingJob = true;
    notifyListeners();
    try {
      final success = await repository.completeJob(
        requestId: requestId,
        service: selectedService,
        subCategory: option,
      );
      if (!success) {
        _lastErrorMessage = 'Could not mark the job complete right now.';
        return false;
      }
      _jobCompleted = true;
      _activeJobCycleId++;
      return true;
    } finally {
      _isCompletingJob = false;
      notifyListeners();
    }
  }

  Future<bool> processPayment() async {
    if (_isProcessingPayment) {
      return false;
    }
    _isProcessingPayment = true;
    notifyListeners();
    try {
      final requestId = _searchReferenceId;
      if (requestId == null || requestId.isEmpty) {
        _lastErrorMessage = 'Missing booking reference for this payment.';
        return false;
      }
      final success = await repository.processPayment(
        requestId: requestId,
        amount: totalInvoiceAmount,
        paymentMethod: _paymentMethod,
      );
      if (!success) {
        _lastErrorMessage = 'Payment could not be processed right now.';
      }
      return success;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  Future<bool> submitRating(int rating) async {
    if (_isSubmittingRating) {
      return false;
    }
    _submittedRating = rating;
    _isSubmittingRating = true;
    notifyListeners();
    final providerId = _matchedProvider?.id;
    final requestId = _searchReferenceId;
    if (providerId == null || requestId == null || requestId.isEmpty) {
      _lastErrorMessage = 'Missing provider or booking reference for rating.';
      _isSubmittingRating = false;
      notifyListeners();
      return false;
    }
    try {
      final success = await repository.submitRating(
        requestId: requestId,
        providerId: providerId,
        rating: rating,
      );
      if (!success) {
        _lastErrorMessage = 'Could not submit your rating right now.';
      }
      return success;
    } finally {
      _isSubmittingRating = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBroadcastRequest({
    String reason = 'user_cancelled',
  }) async {
    if (_isCancellingBroadcast) {
      return false;
    }
    final requestId = _searchReferenceId;
    final option = _selectedSubCategory;
    _isCancellingBroadcast = true;
    notifyListeners();
    try {
      if (requestId != null && requestId.isNotEmpty && option != null) {
        final success = await repository.cancelBroadcast(
          requestId: requestId,
          service: selectedService,
          subCategory: option,
          reason: reason,
        );
        if (!success) {
          _lastErrorMessage = 'Could not cancel the search right now.';
          return false;
        }
      }
      cancelBroadcast();
      return true;
    } finally {
      _isCancellingBroadcast = false;
      notifyListeners();
    }
  }

  Future<void> _startRepositorySearch(
    TMSubCategoryOption option, {
    required int cycleId,
  }) async {
    if (_searchReferenceId == null || _searchReferenceId!.isEmpty) {
      _searchReferenceId = await repository.createBroadcastRequest(
        service: selectedService,
        subCategory: option,
      );
      if (cycleId != _searchCycleId) {
        return;
      }
      _startSnapshotStream(cycleId);
      notifyListeners();
    } else {
      await repository.updateBroadcastStage(
        requestId: _searchReferenceId!,
        service: selectedService,
        subCategory: option,
        stage: _broadcastStage == TMBroadcastStage.expandedSearch
            ? 'expanded_search'
            : 'broadcast',
        searchRadiusKm: _searchRadiusKm,
        attempt: _searchAttempt,
      );
    }
    if (cycleId != _searchCycleId) {
      return;
    }

    final provider = await repository.findProvider(
      requestId: _searchReferenceId ?? '',
      service: selectedService,
      subCategory: option,
      searchRadiusKm: _searchRadiusKm,
      attempt: _searchAttempt,
    );
    if (cycleId != _searchCycleId ||
        _broadcastStage == TMBroadcastStage.failed) {
      return;
    }

    if (provider != null && isSearching) {
      _ticker?.dispose();
      _ticker = null;
      _matchedProvider = provider;
      _broadcastStage = TMBroadcastStage.idle;
      _secondsRemaining = 0;
      notifyListeners();
    }
  }

  Future<void> _requestHardwareIfNeeded(
    TMSubCategoryOption option,
    TMProviderProfile provider, {
    required int cycleId,
  }) async {
    final request = await repository.getHardwareRequest(
      requestId: _searchReferenceId ?? '',
      service: selectedService,
      subCategory: option,
      provider: provider,
    );
    if (cycleId != _activeJobCycleId || _jobCompleted) {
      return;
    }
    if (request != null) {
      emitHardwareRequest(request);
    }
  }

  void _startTicker() {
    _ticker?.dispose();
    _ticker = Ticker((elapsed) {
      final remaining = 60 - elapsed.inSeconds;
      if (remaining == _secondsRemaining) {
        return;
      }

      if (remaining > 0) {
        _secondsRemaining = remaining;
        notifyListeners();
        return;
      }

      if (_broadcastStage == TMBroadcastStage.nearbySearch) {
        final option = _selectedSubCategory;
        _searchRadiusKm = 8;
        _searchAttempt = 2;
        _secondsRemaining = 60;
        _broadcastStage = TMBroadcastStage.expandedSearch;
        _broadcastNotice =
            'Expanding Search... Service Fee may increase by 50-100 per km';
        _startTicker();
        if (option != null) {
          unawaited(_startRepositorySearch(option, cycleId: _searchCycleId));
        }
        notifyListeners();
        return;
      }

      _ticker?.dispose();
      _ticker = null;
      _secondsRemaining = 0;
      _broadcastStage = TMBroadcastStage.failed;
      notifyListeners();
    })
      ..start();
  }

  void _startSnapshotStream(int cycleId) {
    final requestId = _searchReferenceId;
    if (requestId == null || requestId.isEmpty) {
      return;
    }
    _snapshotSubscription?.cancel();
    _snapshotSubscription = repository.watchBookingSnapshot(requestId).listen((
      snapshot,
    ) {
      unawaited(_applySnapshot(snapshot, cycleId));
    });
    unawaited(_syncSnapshot(cycleId));
  }

  Future<void> _syncSnapshot(int cycleId) async {
    final requestId = _searchReferenceId;
    if (requestId == null || requestId.isEmpty || cycleId != _searchCycleId) {
      return;
    }

    final snapshot = await repository.fetchBookingSnapshot(requestId);
    await _applySnapshot(snapshot, cycleId);
  }

  Future<void> _applySnapshot(TMBookingSnapshot? snapshot, int cycleId) async {
    if (snapshot == null || cycleId != _searchCycleId) {
      return;
    }

    var shouldNotify = false;

    if (snapshot.provider != null &&
        (_matchedProvider == null ||
            _matchedProvider!.id != snapshot.provider!.id)) {
      _matchedProvider = snapshot.provider;
      shouldNotify = true;
    }

    if (snapshot.dispatchMode != null &&
        snapshot.dispatchMode != _dispatchMode) {
      _dispatchMode = snapshot.dispatchMode;
      shouldNotify = true;
    }

    if (snapshot.totalPrice != null &&
        snapshot.totalPrice! >= baseLaborCost &&
        snapshot.totalPrice! != totalInvoiceAmount) {
      _approvedHardwareCost = snapshot.totalPrice! - baseLaborCost;
      shouldNotify = true;
    }

    final hardwareRequest = snapshot.hardwareRequest;
    if (hardwareRequest != null &&
        _pendingHardwareRequest == null &&
        _lastHardwareRequestId != hardwareRequest.id) {
      _pendingHardwareRequest = hardwareRequest;
      _lastHardwareRequestId = hardwareRequest.id;
      _hardwareRequestController.add(hardwareRequest);
      shouldNotify = true;
    }

    final stage = snapshot.stage ?? '';
    if (stage == 'cancelled' || snapshot.status == 'cancelled') {
      _ticker?.dispose();
      _ticker = null;
      _broadcastStage = TMBroadcastStage.failed;
      _secondsRemaining = 0;
      shouldNotify = true;
    }
    if (stage == 'matched' ||
        stage == 'provider_accepted' ||
        stage == 'in_progress' ||
        stage == 'hardware_pending' ||
        stage == 'hardware_approved') {
      if (_broadcastStage != TMBroadcastStage.idle) {
        _ticker?.dispose();
        _ticker = null;
        _broadcastStage = TMBroadcastStage.idle;
        _secondsRemaining = 0;
        shouldNotify = true;
      }
    }

    if (stage == 'completed' || snapshot.status == 'completed') {
      if (!_jobCompleted) {
        _jobCompleted = true;
        shouldNotify = true;
      }
    }

    if (stage == 'paid') {
      if (_isProcessingPayment) {
        _isProcessingPayment = false;
        shouldNotify = true;
      }
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchCycleId++;
    _activeJobCycleId++;
    _ticker?.dispose();
    _snapshotSubscription?.cancel();
    _hardwareRequestController.close();
    super.dispose();
  }
}
