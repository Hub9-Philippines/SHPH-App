## MODIFIED Requirements

### Requirement: Radar ripple rendered with native map geometry
The radial ripple scan effect on a proximity-search map SHALL be rendered using a hardware-accelerated Flutter canvas overlay (`CustomPainter` / `MapRadarPulseOverlay`), NOT native Google Maps `Circle` layers updated frame-by-frame over the platform channel. It SHALL be anchored to the projected screen position of the pinned booking/client location.

#### Scenario: Ripple stays pinned during map zoom and drag
- **WHEN** the user zooms or pans the map while the ripple animates
- **THEN** each ring remains centered at the screen position of the pinned marker with no clipping, frame drops, or detachments

#### Scenario: Ripple behaves correctly across all device tiers
- **WHEN** the radar ripple runs on low-end or high-refresh mobile devices
- **THEN** zero platform channel method calls are generated per animation tick, running smoothly at native display refresh rate (60 to 120 FPS)

### Requirement: Smooth 60 fps updates without full-map rebuilds
The ripple SHALL update at a smooth display rate (target 60 to 120 FPS) directly on Flutter's render tree without sending circle updates over the platform bridge, and without rebuilding the GoogleMap widget tree.

#### Scenario: Ticks update only canvas painter
- **WHEN** the ripple animation ticks
- **THEN** only the lightweight CustomPainter repaints, keeping CPU and bridge utilization near zero

#### Scenario: High tick rate during animation
- **WHEN** the ripple animates continuously
- **THEN** frame times remain within the 16 ms (or 8 ms on 120 Hz) frame budget without stalling the UI thread
