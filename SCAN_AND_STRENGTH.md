# WiFi Scanning and Signal Strength Implementation

## Overview
This document explains how wifi network scanning and signal strength representation was implemented using Apple's CoreWLAN framework.

## WiFi Scanning

### Core Components
**WiFiManager** (`WiFiManager.swift:4-54`) - Handles all CoreWLAN interactions

**Key Method: `scanNetworks()`** (`WiFiManager.swift:8-38`)

1. Get WiFi interface from `CWWiFiClient.shared().interface()`
2. Call `interface.scanForNetworks(withSSID: nil)` to scan all networks
3. Filter out networks with nil/empty SSIDs
4. Deduplicate by SSID, keeping the one with strongest signal (highest RSSI)
5. Sort alphabetically by SSID

### State Management
**WiFiState** (`WiFiState.swift:6-90`) - Observable class that coordinates scanning

- Uses `LocationManager` to check for required location permissions
- Starts automatic scanning every 10 seconds via Timer (`WiFiState.swift:35`)
- Runs scans on background queue (`DispatchQueue.global`) to avoid blocking UI
- Updates networks array on main thread for UI updates

### Location Permission Requirement
**LocationManager** (`LocationManager.swift:4-33`) - Handles CoreLocation permissions

WiFi scanning on macOS requires "Always" location authorization. This is a CoreWLAN requirement.

- Request with `CLLocationManager.requestAlwaysAuthorization()`
- Monitor status changes via delegate callback
- UI shows permission prompt if not authorized

## Signal Strength Representation

### RSSI to Percentage Conversion
**Formula** (`MenuBarView.swift:154`):
```
percent = max(0, min(100, (rssiValue + 100) * 2))
```

### How It Works
- RSSI (Received Signal Strength Indicator) is in dBm, typically ranging from -100 (worst) to 0 (best)
- Add 100 to shift range to 0-100
- Multiply by 2 to scale to 0-200
- Clamp to 0-100 range

### Examples
- -50 dBm → 100% (excellent)
- -70 dBm → 60% (good)
- -90 dBm → 20% (poor)
- -100 dBm → 0% (unusable)

### Display
Signal strength is shown as a percentage next to each network name in the UI (`MenuBarView.swift:129`).

## Network Deduplication
When scanning, the same SSID may appear multiple times (different access points). The implementation handles this by:

1. Grouping networks by SSID
2. Selecting the one with highest RSSI value (strongest signal)
3. This ensures each SSID appears once with its best signal strength

Code location: `WiFiManager.swift:25-26`

## Key Framework Details

### CoreWLAN
Apple's framework for WiFi operations on macOS.

**Main Classes Used:**
- `CWWiFiClient` - Entry point for WiFi operations
- `CWInterface` - Represents the WiFi interface
- `CWNetwork` - Represents a discovered network with properties like `ssid`, `rssiValue`

### CoreLocation
Required for WiFi scanning permissions.

**Why needed:** macOS considers WiFi information to be location-sensitive data, so location permission is required to scan networks.
