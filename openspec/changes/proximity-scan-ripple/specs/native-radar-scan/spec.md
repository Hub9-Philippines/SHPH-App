## Purpose

Defines the native-geometry map scanning ripple used on the proximity-search maps: a geographically-true, looping radar effect that expands to 3000 meters over 30 seconds using native map circle layers, stable under zoom and rotation and smooth at 60 fps.

## ADDED Requirements

### Requirement: Radar ripple rendered with native map geometry
The radial ripple effect on a proximity-search map SHALL be rendered using the map SDK's native circle layers (Google Maps `Circle`s), NOT screen-pixel overlay widgets or widget-bounded CustomPainters. It SHALL be centered on the pinned booking/client location.

#### Scenario: Ripple stays pinned during map zoom
- **WHEN** the user zooms the map while the ripple animates
- **THEN** each ring remains anchored to the pinned location and its on-screen size scales with the map tiles, with no clipping or drift

#### Scenario: Ripple behaves correctly during map rotation
- **WHEN** the map is rotated while the ripple animates
- **THEN** the rings stay centered on the pinned location and do not shear, detach, or get clipped at the widget edge

### Requirement: Geographically true radius expansion
The ripple rings SHALL expand from 0 to exactly 3000 meters of geographic radius, so their diameter corresponds to real-world ground distance around the pinned location.

#### Scenario: Ring radius equals real-world meters at any instant
- **WHEN** the animation is at fraction `t` of its cycle
- **THEN** the outer ring radius on the native layer equals `3000 * ease(t)` meters on the ground, independent of zoom level

### Requirement: Fixed 30-second looping animation
The full ripple cycle (from smallest to maximum radius) SHALL take exactly 30 seconds and loop indefinitely while the search screen is active.

#### Scenario: Full cycle duration
- **WHEN** the ripple animation runs continuously for 30 seconds
- **THEN** the outermost ring has traversed one complete expansion from 0 to 3000 m and begins the next cycle

#### Scenario: Loop runs until screen leaves
- **WHEN** the search screen is still mounted and searching
- **THEN** the ripple keeps looping with no gap at the cycle boundary

### Requirement: Staggered fading rings radar look
The ripple SHALL show at least 2, and targeted 3, staggered expanding rings that fade out in opacity as they approach the maximum radius, producing a radar-scan sweep.

#### Scenario: Multiple visible rings
- **WHEN** the animation is mid-cycle
- **THEN** more than one ring is simultaneously visible at different radii

#### Scenario: Ring opacity fades at max radius
- **WHEN** a ring reaches the maximum radius
- **THEN** its opacity has fallen to near zero so the sweep fades instead of popping

### Requirement: Smooth 60 fps updates without full-map rebuilds
The ripple SHALL update at a smooth display rate (target 60 fps) and SHALL NOT rebuild the entire map widget tree on every animation tick; only the circle-layer data that changes each tick is updated.

#### Scenario: Ticks update only circle data
- **WHEN** the ripple animation ticks
- **THEN** the map, markers, and all non-ripple children are not rebuilt, and the ripple layer updates its radius/opacity per tick

#### Scenario: High tick rate during animation
- **WHEN** the ripple animates for 1 second
- **THEN** roughly 60 geometry updates occur with the visible motion appearing continuous

### Requirement: Resource cleanup on unmount
The ripple animation controller and any associated timers SHALL be disposed/cancelled when the owning widget is unmounted, leaving no running tickers behind.

#### Scenario: Leaving the search screen
- **WHEN** the search screen is popped or replaced
- **THEN** the animation is stopped and its controller disposed, and no exceptions or leaks occur from the disposed ticker

### Requirement: Ripple absence on terminal states
When the search has ended (matched, timed out, or failed), the ripple SHALL stop and disappear (native circles removed), leaving the terminal UI clear.

#### Scenario: Provider matched stops scan
- **WHEN** a provider is matched
- **THEN** the ripple rings are removed from the map and the matched UI is shown without residual rings

#### Scenario: Timeout clears scan
- **WHEN** the search times out or fails
- **THEN** the ripple rings are removed from the map