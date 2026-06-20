import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_place_picker.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'pin_location_model.dart';

export 'pin_location_model.dart';

class PinLocationWidget extends StatefulWidget {
  const PinLocationWidget({
    required this.latlong,
    super.key,
  });

  final LatLng? latlong;

  static String routeName = 'PinLocation';
  static String routePath = '/pinLocation';

  @override
  State<PinLocationWidget> createState() => _PinLocationWidgetState();
}

class _PinLocationWidgetState extends State<PinLocationWidget> {
  late PinLocationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, PinLocationModel.new);
    if (widget.latlong != null) {
      _model.googleMapsCenter = widget.latlong;
      _model.latlng = widget.latlong;
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          backgroundColor: AppTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      wrapWithModel(
                        model: _model.backButtonModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const BackButtonWidget(),
                      ),
                      FlutterFlowPlacePicker(
                        iOSGoogleMapsApiKey:
                            'AIzaSyCyNmGRVmX5--jXElXLS6HVXriyPTGGnoY',
                        androidGoogleMapsApiKey:
                            'AIzaSyCyNmGRVmX5--jXElXLS6HVXriyPTGGnoY',
                        webGoogleMapsApiKey:
                            'AIzaSyCyNmGRVmX5--jXElXLS6HVXriyPTGGnoY',
                        onSelect: (place) async {
                          safeSetState(() => _model.placePickerValue = place);
                        },
                        defaultText: 'Search a location',
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xE357636C),
                          size: 24,
                        ),
                        buttonOptions: FFButtonOptions(
                          width: 260,
                          height: 50,
                          color: Colors.transparent,
                          textAlign: TextAlign.start,
                          textStyle: AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: AppTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle:
                                      AppTheme.of(context).titleSmall.fontStyle,
                                ),
                                color: const Color(0xE357636C),
                                letterSpacing: 0,
                                fontWeight:
                                    AppTheme.of(context).titleSmall.fontWeight,
                                fontStyle:
                                    AppTheme.of(context).titleSmall.fontStyle,
                              ),
                          elevation: 0,
                          borderSide: BorderSide(
                            color: AppTheme.of(context).alternate,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 10,
                        buttonSize: 50,
                        fillColor: AppTheme.of(context).primary,
                        icon: Icon(
                          Icons.location_pin,
                          color: AppTheme.of(context).info,
                          size: 24,
                        ),
                        onPressed: () async {
                          await _model.googleMapsController.future.then(
                            (c) => c.animateCamera(
                              CameraUpdate.newLatLng(
                                _model.placePickerValue.latLng.toGoogleMaps(),
                              ),
                            ),
                          );
                          _model.latlng = _model.googleMapsCenter;
                          safeSetState(() {});
                        },
                      ),
                    ].divide(const SizedBox(width: 10)),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FlutterFlowGoogleMap(
                        controller: _model.googleMapsController,
                        onCameraIdle: (latLng) => safeSetState(
                            () => _model.googleMapsCenter = latLng),
                        initialLocation: _model.googleMapsCenter ??=
                            widget.latlong ?? const LatLng(14.5995, 120.9842),
                        markers: [
                          FlutterFlowMarker(
                            'selected_pin',
                            _model.googleMapsCenter ??
                                widget.latlong ??
                                const LatLng(14.5995, 120.9842),
                          ),
                        ],
                        markerColor: GoogleMarkerColor.red,
                        mapType: MapType.normal,
                        style: GoogleMapStyle.standard,
                        initialZoom: 14,
                        allowInteraction: true,
                        allowZoom: true,
                        showZoomControls: false,
                        showLocation: true,
                        showCompass: false,
                        showMapToolbar: false,
                        showTraffic: false,
                        centerMapOnMarkerTap: true,
                        mapTakesGesturePreference: false,
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: PointerInterceptor(
                          intercepting: isWeb,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 10, 80),
                            child: FlutterFlowIconButton(
                              borderRadius: 50,
                              buttonSize: 40,
                              fillColor: AppTheme.of(context).primaryBackground,
                              icon: FaIcon(
                                FontAwesomeIcons.compass,
                                color: AppTheme.of(context).primaryText,
                                size: 20,
                              ),
                              onPressed: () async {
                                currentUserLocationValue =
                                    await getCurrentUserLocation(
                                  defaultLocation: const LatLng(0, 0),
                                );
                                if (currentUserLocationValue != null) {
                                  await _model.googleMapsController.future.then(
                                    (c) => c.animateCamera(
                                      CameraUpdate.newLatLng(
                                          currentUserLocationValue!
                                              .toGoogleMaps()),
                                    ),
                                  );
                                  _model.latlng = _model.googleMapsCenter;
                                  safeSetState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      // Address preview card
                      if (_model.placePickerValue.name.isNotEmpty ||
                          _model.placePickerValue.address.isNotEmpty)
                        Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: PointerInterceptor(
                            intercepting: isWeb,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 0, 16, 90),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context).primaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 8,
                                      color: Color(0x26000000),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: AppTheme.of(context).primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (_model
                                              .placePickerValue.name.isNotEmpty)
                                            Text(
                                              _model.placePickerValue.name,
                                              style: AppTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          if (_model.placePickerValue.address
                                              .isNotEmpty)
                                            Text(
                                              _model.placePickerValue.address,
                                              style: AppTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Submit button
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: PointerInterceptor(
                          intercepting: isWeb,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 25),
                            child: FFButtonWidget(
                              onPressed: () async {
                                final center = _model.googleMapsCenter;
                                if (center == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please select a location on the map'),
                                    ),
                                  );
                                  return;
                                }

                                final place = _model.placePickerValue;
                                String? address;
                                if (place.address.isNotEmpty) {
                                  address = place.address;
                                } else if (place.name.isNotEmpty) {
                                  address = place.name;
                                }

                                context.pop({
                                  'latitude': center.latitude,
                                  'longitude': center.longitude,
                                  'address': address,
                                });
                              },
                              text: 'Submit',
                              options: FFButtonOptions(
                                width: 200,
                                height: 50,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 16, 0),
                                iconPadding: EdgeInsetsDirectional.zero,
                                color: AppTheme.of(context).primary,
                                textStyle:
                                    AppTheme.of(context).titleSmall.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: AppTheme.of(context)
                                                .titleSmall
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .titleSmall
                                                .fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0,
                                          fontWeight: AppTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                        ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
