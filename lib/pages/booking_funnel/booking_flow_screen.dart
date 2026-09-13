import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/backend/supabase/database/tables/addresses.dart';
import '/components/cupertino_ui/app_pickers.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/flutter_flow/lat_lng.dart' as ff_latlng;
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/pages/pin_location/pin_location_widget.dart';
import '/theme/app_theme.dart';
import 'booking_controller.dart';
import 'booking_models.dart';
import 'setup/booking_setup_screen.dart';
import 'widgets/booking_flow_route.dart';
import 'widgets/booking_step_spine.dart';
import 'widgets/location_confirmation_panel.dart';
import 'widgets/time_selection_panel.dart';

class BookingFlowScreen extends StatelessWidget {
  const BookingFlowScreen({
    required this.selectedService,
    this.initialUrgency,
    this.initialScheduledDate,
    this.initialScheduledTime,
    super.key,
  });

  static String routeName = 'BookingFlow';
  static String routePath = '/booking-flow';

  final ServiceListing selectedService;
  final BookingUrgency? initialUrgency;
  final DateTime? initialScheduledDate;
  final TimeOfDay? initialScheduledTime;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) {
          final l10n = AppLocalizations.of(context)!;
          final appState = FFAppState();
          final initialDraft = BookingDraft(
            urgency: initialUrgency ?? BookingUrgency.rightNow,
            rooms: 1,
            cleaningType: ServiceType.standard,
            paymentMethod: BookingPaymentMethod.gcash,
            address: BookingAddress(
              label: appState.selectedAddressLabel.isNotEmpty
                  ? appState.selectedAddressLabel
                  : l10n.bfHome,
              line1: appState.selectedAddressLine1.isNotEmpty
                  ? appState.selectedAddressLine1
                  : '123 Example Street',
              city: appState.selectedAddressCity.isNotEmpty
                  ? appState.selectedAddressCity
                  : 'Metro Manila',
            ),
            latitude: appState.selectedLatitude ?? 14.5995,
            longitude: appState.selectedLongitude ?? 120.9842,
            serviceListingId: selectedService.id,
            serviceTitle: selectedService.title,
            serviceCategoryName: selectedService.categoryName,
            serviceDescription: selectedService.description,
            serviceImageUrl: selectedService.thumbnail,
            serviceBasePrice: selectedService.basePrice,
            servicePriceUnit: selectedService.priceUnit,
            scheduledDate: initialScheduledDate,
            scheduledTime: initialScheduledTime,
          );
          return BookingFlowController(initialDraft: initialDraft);
        },
        child: const _CleaningBookingFlowView(),
      );
}

class _CleaningBookingFlowView extends StatefulWidget {
  const _CleaningBookingFlowView();

  @override
  State<_CleaningBookingFlowView> createState() =>
      _CleaningBookingFlowViewState();
}

class _CleaningBookingFlowViewState extends State<_CleaningBookingFlowView> {
  late LatLng _center;
  bool _isLocationConfirmed = false;
  GoogleMapController? _mapController;
  late final bool _prefersSelectedAddressCenter;

  @override
  void initState() {
    super.initState();
    final draft = context.read<BookingFlowController>().draft;
    _center = LatLng(draft.latitude, draft.longitude);
    _prefersSelectedAddressCenter = FFAppState().selectedLatitude != null &&
        FFAppState().selectedLongitude != null;
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) {
        return;
      }

      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        if (!_prefersSelectedAddressCenter) {
          _center = location;
        }
      });
      if (!_prefersSelectedAddressCenter) {
        context.read<BookingFlowController>().setCoordinates(
              latitude: position.latitude,
              longitude: position.longitude,
            );
        await _animateToCurrentLocation();
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _animateToCurrentLocation() async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: _center, zoom: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final mediaQuery = MediaQuery.of(context);
    // The bottom sheet (~300px tall) overlaps the map's lower part: the map
    // stays full-bleed behind it, but the camera centers the pin in the
    // visible region between the top card and the sheet's top edge.
    final sheetOverlap = 300.0;
    final visibleTop = mediaQuery.padding.top + 96;
    final visibleBottom = mediaQuery.padding.bottom + sheetOverlap;
    final mapPadding = EdgeInsets.only(
      // Google Maps centers the camera target inside the padded region, so
      // equal-ish insets above/below place the pin in the middle of the area
      // visible between the top card and the overlapping bottom sheet.
      top: visibleTop,
      right: 16,
      bottom: visibleBottom,
    );

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 16,
              ),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              padding: mapPadding,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                _animateToCurrentLocation();
              },
              onCameraMove: (position) {
                _center = position.target;
              },
              onCameraIdle: () {
                if (!mounted) {
                  return;
                }
                context.read<BookingFlowController>().setCoordinates(
                      latitude: _center.latitude,
                      longitude: _center.longitude,
                    );
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected_booking_pin'),
                  position: _center,
                ),
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.26),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Consumer<BookingFlowController>(
            builder: (context, controller, _) => Positioned(
              top: mediaQuery.padding.top + 12,
              left: 16,
              right: 16,
              child: _FlowTopCard(
                stepIndex: _isLocationConfirmed ? 1 : 0,
                title: controller.selectedServiceLabel(l10n),
                subtitle: _heroSubtitle(controller, l10n),
                address: controller.draft.address,
                onBack: () {
                  if (_isLocationConfirmed) {
                    setState(() {
                      _isLocationConfirmed = false;
                    });
                    return;
                  }
                  Navigator.of(context).pop();
                },
                onEditAddress: () async {
                  await _editBookingAddress(context, controller);
                },
              ),
            ),
          ),
          Consumer<BookingFlowController>(
            builder: (context, controller, _) => Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: _isLocationConfirmed
                    ? TimeSelectionPanel(
                        serviceTitle: controller.selectedServiceLabel(l10n),
                        urgency: controller.draft.urgency,
                        scheduledDate: controller.draft.scheduledDate,
                        scheduledTime: controller.draft.scheduledTime,
                        onUrgencyChanged: controller.setUrgency,
                        onPickLaterToday: _pickLaterToday,
                        onPickScheduledSlot: _pickScheduledSlot,
                        onNext: () => _openServiceConfig(context, controller),
                      )
                    : LocationConfirmationPanel(
                        address: controller.draft.address,
                        serviceTitle: controller.selectedServiceLabel(l10n),
                        serviceCategoryName:
                            controller.draft.serviceCategoryName,
                        onEdit: () async {
                          await _editBookingPin(context, controller);
                        },
                        onConfirm: () {
                          setState(() {
                            _isLocationConfirmed = true;
                          });
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLaterToday(BuildContext context) async {
    final controller = context.read<BookingFlowController>();
    final outerContext = context;

    final picked = await showAppTimePicker(
      context: outerContext,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) {
      return;
    }
    if (!outerContext.mounted) {
      return;
    }

    controller.setSchedule(time: picked, urgency: BookingUrgency.laterToday);
  }

  Future<void> _pickScheduledSlot(BuildContext context) async {
    final controller = context.read<BookingFlowController>();
    final date = await showAppDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }
    final time = await showAppTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) {
      return;
    }

    if (!context.mounted) {
      return; // Safe check before calling updates
    }

    controller.setSchedule(
      date: date,
      time: time,
      urgency: BookingUrgency.scheduled,
    );
  }

  Future<void> _openServiceConfig(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      buildBookingFlowRoute<void>(
        ChangeNotifierProvider.value(
          value: controller,
          child: const BookingSetupScreen(),
        ),
      ),
    );
  }

  Future<void> _editBookingAddress(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final result = await showModalBottomSheet<AddressesRow>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: const EditAddressWidget(),
        ),
      ),
    );
    if (!context.mounted || result == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;

    final appState = FFAppState();
    controller.setAddress(
      BookingAddress(
        label: appState.selectedAddressLabel.isNotEmpty
            ? appState.selectedAddressLabel
            : (result.addressLine2 ?? l10n.bfAddress),
        line1: appState.selectedAddressLine1.isNotEmpty
            ? appState.selectedAddressLine1
            : (result.addressLine1 ?? ''),
        city: appState.selectedAddressCity.isNotEmpty
            ? appState.selectedAddressCity
            : (result.city ?? ''),
      ),
    );

    final latitude = appState.selectedLatitude ?? result.latitude;
    final longitude = appState.selectedLongitude ?? result.longitude;
    if (latitude == null || longitude == null) {
      return;
    }

    controller.setCoordinates(latitude: latitude, longitude: longitude);
    setState(() {
      _center = LatLng(latitude, longitude);
      _isLocationConfirmed = false;
    });
    await _animateToCurrentLocation();
  }

  Future<void> _editBookingPin(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final appState = FFAppState();
    final currentLocation =
        appState.selectedLatitude != null && appState.selectedLongitude != null
            ? ff_latlng.LatLng(
                appState.selectedLatitude!,
                appState.selectedLongitude!,
              )
            : ff_latlng.LatLng(
                controller.draft.latitude,
                controller.draft.longitude,
              );

    final result = await context.pushNamed(
      PinLocationWidget.routeName,
      extra: currentLocation,
    );
    if (!context.mounted || result is! Map<String, dynamic>) {
      return;
    }

    final latitude = result['latitude'] as double?;
    final longitude = result['longitude'] as double?;
    if (latitude == null || longitude == null) {
      return;
    }

    final updatedLine1 =
        ((result['address'] as String?)?.trim().isNotEmpty ?? false)
            ? (result['address'] as String).trim()
            : (appState.selectedAddressLine1.isNotEmpty
                ? appState.selectedAddressLine1
                : controller.draft.address.line1);
    final updatedLabel = appState.selectedAddressLabel.isNotEmpty
        ? appState.selectedAddressLabel
        : controller.draft.address.label;
    final updatedCity = appState.selectedAddressCity.isNotEmpty
        ? appState.selectedAddressCity
        : controller.draft.address.city;

    if (appState.selectedAddressId != null) {
      // Address persistence not exposed by SHPH API; keep in-app state only.
    }

    appState.setSelectedAddress(
      id: appState.selectedAddressId,
      label: updatedLabel,
      line1: updatedLine1,
      city: updatedCity,
      latitude: latitude,
      longitude: longitude,
    );

    controller
      ..setAddress(
        BookingAddress(
          label: updatedLabel,
          line1: updatedLine1,
          city: updatedCity,
        ),
      )
      ..setCoordinates(latitude: latitude, longitude: longitude);

    setState(() {
      _center = LatLng(latitude, longitude);
      _isLocationConfirmed = false;
    });
    await _animateToCurrentLocation();
  }

  String _heroSubtitle(BookingFlowController controller, AppLocalizations l10n) {
    final category = controller.draft.serviceCategoryName;
    if (category != null && category.isNotEmpty) {
      return l10n.bfHeroCategoryReady(category);
    }
    return l10n.bfHeroFastDispatch;
  }
}

class _FlowTopCard extends StatelessWidget {
  const _FlowTopCard({
    required this.stepIndex,
    required this.title,
    required this.subtitle,
    required this.address,
    required this.onBack,
    required this.onEditAddress,
  });

  final int stepIndex;
  final String title;
  final String subtitle;
  final BookingAddress address;
  final VoidCallback onBack;
  final Future<void> Function() onEditAddress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: theme.secondaryBackground,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bfStepOfCount(stepIndex + 1, 4),
                      style: theme.labelMedium.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: theme.titleLarge.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BookingStepSpine(steps: [
            l10n.bfLocation,
            l10n.bfTime,
            l10n.bfDetails,
            l10n.bfReview,
          ], currentStep: stepIndex),
          const SizedBox(height: 14),
          _AddressBanner(
            address: address,
            onTap: onEditAddress,
          ),
        ],
      ),
    );
  }
}

class _AddressBanner extends StatelessWidget {
  const _AddressBanner({required this.address, required this.onTap});

  final BookingAddress address;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.place_rounded, color: theme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.line1}, ${address.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_rounded, color: theme.secondaryText, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
