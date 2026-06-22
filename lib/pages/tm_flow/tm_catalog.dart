import 'package:flutter/material.dart';

import '/models/service_listing.dart';

import 'tm_models.dart';

List<TMSubCategoryOption> tmSubCategoriesForService(ServiceListing service) {
  final fingerprint =
      '${service.title} ${service.categoryName ?? ''}'.toLowerCase();

  if (fingerprint.contains('lock')) {
    return const [
      TMSubCategoryOption(
        id: 'home_lockout',
        title: 'Home Lockout',
        subtitle: 'Door unlocking, basic lock access, and urgent entry help.',
        icon: Icons.key_rounded,
        estimateMin: 400,
        estimateMax: 600,
      ),
      TMSubCategoryOption(
        id: 'lock_repair',
        title: 'Lock Repair',
        subtitle: 'Minor repairs, stuck cylinders, and latch adjustments.',
        icon: Icons.lock_open_rounded,
        estimateMin: 550,
        estimateMax: 900,
      ),
      TMSubCategoryOption(
        id: 'lock_replacement',
        title: 'Lock Replacement',
        subtitle: 'Replace damaged locks. Hardware cost may be added later.',
        icon: Icons.door_front_door_rounded,
        estimateMin: 700,
        estimateMax: 1200,
      ),
    ];
  }

  if (fingerprint.contains('plumb')) {
    return const [
      TMSubCategoryOption(
        id: 'pipe_leak',
        title: 'Pipe Leak Repair',
        subtitle: 'Urgent leak isolation, sealing, and connector replacement.',
        icon: Icons.water_drop_rounded,
        estimateMin: 500,
        estimateMax: 850,
      ),
      TMSubCategoryOption(
        id: 'faucet_issue',
        title: 'Faucet / Valve Issue',
        subtitle: 'Loose fittings, weak flow, and valve troubleshooting.',
        icon: Icons.plumbing_rounded,
        estimateMin: 450,
        estimateMax: 800,
      ),
      TMSubCategoryOption(
        id: 'drain_clog',
        title: 'Drain Clog Clearing',
        subtitle: 'Sink, bathroom, and floor drain unclogging support.',
        icon: Icons.cleaning_services_rounded,
        estimateMin: 600,
        estimateMax: 950,
      ),
    ];
  }

  if (fingerprint.contains('electric')) {
    return const [
      TMSubCategoryOption(
        id: 'power_outlet_issue',
        title: 'Outlet / Switch Issue',
        subtitle: 'Fault isolation, rewiring checks, and safe restoration.',
        icon: Icons.power_outlined,
        estimateMin: 500,
        estimateMax: 850,
      ),
      TMSubCategoryOption(
        id: 'breaker_trip',
        title: 'Breaker Trip Investigation',
        subtitle: 'Short circuit diagnostics and load troubleshooting.',
        icon: Icons.electrical_services_rounded,
        estimateMin: 650,
        estimateMax: 1100,
      ),
      TMSubCategoryOption(
        id: 'lighting_issue',
        title: 'Lighting Repair',
        subtitle: 'Fixture checks, ballast replacement, and rewiring.',
        icon: Icons.lightbulb_rounded,
        estimateMin: 450,
        estimateMax: 780,
      ),
    ];
  }

  if (fingerprint.contains('appliance')) {
    return const [
      TMSubCategoryOption(
        id: 'washer_issue',
        title: 'Washer / Dryer Issue',
        subtitle: 'Diagnostics, disassembly, and repair recommendations.',
        icon: Icons.local_laundry_service_rounded,
        estimateMin: 650,
        estimateMax: 1200,
      ),
      TMSubCategoryOption(
        id: 'refrigerator_issue',
        title: 'Refrigerator Issue',
        subtitle: 'Cooling, leakage, or electrical troubleshooting visit.',
        icon: Icons.kitchen_rounded,
        estimateMin: 700,
        estimateMax: 1400,
      ),
      TMSubCategoryOption(
        id: 'small_appliance_repair',
        title: 'Small Appliance Repair',
        subtitle: 'Inspection and repair of common home appliances.',
        icon: Icons.home_repair_service_rounded,
        estimateMin: 500,
        estimateMax: 900,
      ),
    ];
  }

  return const [
    TMSubCategoryOption(
      id: 'quick_repair',
      title: 'Quick Repair Visit',
      subtitle: 'Fast troubleshooting and basic repair support.',
      icon: Icons.build_circle_rounded,
      estimateMin: 450,
      estimateMax: 750,
    ),
    TMSubCategoryOption(
      id: 'diagnostic_visit',
      title: 'Diagnostic Visit',
      subtitle: 'Problem isolation before labor and materials are finalized.',
      icon: Icons.manage_search_rounded,
      estimateMin: 400,
      estimateMax: 650,
    ),
    TMSubCategoryOption(
      id: 'urgent_assistance',
      title: 'Urgent Assistance',
      subtitle: 'Immediate help for time-sensitive home service issues.',
      icon: Icons.crisis_alert_rounded,
      estimateMin: 550,
      estimateMax: 950,
    ),
  ];
}
