import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';

import 'tm_models.dart';

List<TMSubCategoryOption> tmSubCategoriesForService(
  ServiceListing service,
  AppLocalizations l10n,
) {
  final fingerprint =
      '${service.title} ${service.categoryName ?? ''}'.toLowerCase();

  if (fingerprint.contains('lock')) {
    return [
      TMSubCategoryOption(
        id: 'home_lockout',
        title: 'Home Lockout',
        titleKey: 'tmSubHomeLockout',
        subtitle: l10n.tmCatHomeLockout,
        icon: Icons.key_rounded,
        estimateMin: 400,
        estimateMax: 600,
      ),
      TMSubCategoryOption(
        id: 'lock_repair',
        title: 'Lock Repair',
        titleKey: 'tmSubLockRepair',
        subtitle: l10n.tmCatLockRepair,
        icon: Icons.lock_open_rounded,
        estimateMin: 550,
        estimateMax: 900,
      ),
      TMSubCategoryOption(
        id: 'lock_replacement',
        title: 'Lock Replacement',
        titleKey: 'tmSubLockReplace',
        subtitle: l10n.tmCatLockReplacement,
        icon: Icons.door_front_door_rounded,
        estimateMin: 700,
        estimateMax: 1200,
      ),
    ];
  }

  if (fingerprint.contains('plumb')) {
    return [
      TMSubCategoryOption(
        id: 'pipe_leak',
        title: 'Pipe Leak Repair',
        titleKey: 'tmSubPipeLeak',
        subtitle: l10n.tmCatPipeLeak,
        icon: Icons.water_drop_rounded,
        estimateMin: 500,
        estimateMax: 850,
      ),
      TMSubCategoryOption(
        id: 'faucet_issue',
        title: 'Faucet / Valve Issue',
        titleKey: 'tmSubFaucetValve',
        subtitle: l10n.tmCatFaucetIssue,
        icon: Icons.plumbing_rounded,
        estimateMin: 450,
        estimateMax: 800,
      ),
      TMSubCategoryOption(
        id: 'drain_clog',
        title: 'Drain Clog Clearing',
        titleKey: 'tmSubDrainClog',
        subtitle: l10n.tmCatDrainClog,
        icon: Icons.cleaning_services_rounded,
        estimateMin: 600,
        estimateMax: 950,
      ),
    ];
  }

  if (fingerprint.contains('electric')) {
    return [
      TMSubCategoryOption(
        id: 'power_outlet_issue',
        title: 'Outlet / Switch Issue',
        titleKey: 'tmSubOutletSwitch',
        subtitle: l10n.tmCatOutletIssue,
        icon: Icons.power_outlined,
        estimateMin: 500,
        estimateMax: 850,
      ),
      TMSubCategoryOption(
        id: 'breaker_trip',
        title: 'Breaker Trip Investigation',
        titleKey: 'tmSubBreakerTrip',
        subtitle: l10n.tmCatBreakerTrip,
        icon: Icons.electrical_services_rounded,
        estimateMin: 650,
        estimateMax: 1100,
      ),
      TMSubCategoryOption(
        id: 'lighting_issue',
        title: 'Lighting Repair',
        titleKey: 'tmSubLightingRepair',
        subtitle: l10n.tmCatLighting,
        icon: Icons.lightbulb_rounded,
        estimateMin: 450,
        estimateMax: 780,
      ),
    ];
  }

  if (fingerprint.contains('appliance')) {
    return [
      TMSubCategoryOption(
        id: 'washer_issue',
        title: 'Washer / Dryer Issue',
        titleKey: 'tmSubWasherDryer',
        subtitle: l10n.tmCatWasherDryer,
        icon: Icons.local_laundry_service_rounded,
        estimateMin: 650,
        estimateMax: 1200,
      ),
      TMSubCategoryOption(
        id: 'refrigerator_issue',
        title: 'Refrigerator Issue',
        titleKey: 'tmSubRefrigerator',
        subtitle: l10n.tmCatRefrigerator,
        icon: Icons.kitchen_rounded,
        estimateMin: 700,
        estimateMax: 1400,
      ),
      TMSubCategoryOption(
        id: 'small_appliance_repair',
        title: 'Small Appliance Repair',
        titleKey: 'tmSubSmallAppliance',
        subtitle: l10n.tmCatSmallAppliance,
        icon: Icons.home_repair_service_rounded,
        estimateMin: 500,
        estimateMax: 900,
      ),
    ];
  }

  return [
    TMSubCategoryOption(
      id: 'quick_repair',
      title: 'Quick Repair Visit',
      titleKey: 'tmSubQuickRepair',
      subtitle: l10n.tmCatQuickRepair,
      icon: Icons.build_circle_rounded,
      estimateMin: 450,
      estimateMax: 750,
    ),
    TMSubCategoryOption(
      id: 'diagnostic_visit',
      title: 'Diagnostic Visit',
      titleKey: 'tmSubDiagnostic',
      subtitle: l10n.tmCatDiagnostic,
      icon: Icons.manage_search_rounded,
      estimateMin: 400,
      estimateMax: 650,
    ),
    TMSubCategoryOption(
      id: 'urgent_assistance',
      title: 'Urgent Assistance',
      titleKey: 'tmSubUrgent',
      subtitle: l10n.tmCatUrgentAssistance,
      icon: Icons.crisis_alert_rounded,
      estimateMin: 550,
      estimateMax: 950,
    ),
  ];
}
