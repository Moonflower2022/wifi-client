# WiFi Client - Implementation Plan

## Overview
Native macOS menu bar app for intelligent WiFi management with auto-join, monitoring, security analysis, and credential management.

## Architecture

### Core Components
1. **WiFiManager** - CoreWLAN wrapper for network operations
2. **ConnectionMonitor** - Speed testing, quality tracking, notifications
3. **AutoJoinEngine** - Priority-based network selection
4. **SecurityAnalyzer** - Network security assessment
5. **CredentialVault** - Password storage with sharing
6. **PreferencesWindow** - SwiftUI settings interface

### Data Storage
- UserDefaults: preferences, priority lists, blacklists
- Keychain: WiFi passwords
- SQLite: historical speed data, network database

## Phase 1: Auto-Join Management (Priority Focus)

### 1.1 Network Priority System
**File**: `Sources/WiFiClient/AutoJoinEngine.swift`
- Priority levels: High, Medium, Low, Never
- Manual ordering within priority groups
- Blacklist functionality
- Smart switching based on signal + speed

**File**: `Sources/WiFiClient/NetworkPreferences.swift`
- Store network preferences
- CRUD operations for priority lists
- Persist to UserDefaults

### 1.2 Auto-Join Logic
**File**: `Sources/WiFiClient/ConnectionStrategy.swift`
- Scan available networks every 10s when disconnected
- Compare by: priority > signal > historical speed
- Auto-connect to best match
- Configurable auto-join on/off

### 1.3 Connection Progress UI
**File**: `Sources/WiFiClient/ConnectionStatusView.swift`
- Show connection attempts in menu bar
- Progress indicators
- Error explanations with actionable advice:
  - "Weak signal - move closer"
  - "Wrong password - update credentials"
  - "Network full - try again later"

## Phase 2: Monitoring & Notifications

### 2.1 Speed Tracking
**File**: `Sources/WiFiClient/SpeedMonitor.swift`
- Periodic speed tests (configurable interval)
- Track: download, upload, latency, packet loss
- Store historical data in SQLite
- Calculate baseline speeds per network

**File**: `Sources/WiFiClient/SpeedTest.swift`
- Simple HTTP-based speed test
- Use multiple endpoints for accuracy
- Non-intrusive background testing

### 2.2 Poor Connection Alerts
**File**: `Sources/WiFiClient/NotificationManager.swift`
- Alert when speed < 50% of baseline
- Alert on connection drops
- Alert on high latency (>200ms)
- User-configurable thresholds
- macOS notification center integration

### 2.3 Speed Visualization
**File**: `Sources/WiFiClient/SpeedGraphView.swift`
- Real-time graph in menu bar window
- Historical view in preferences
- Compare current vs typical speed
- Color coding: green/yellow/red

## Phase 3: Security Analysis

### 3.1 Network Security Check
**File**: `Sources/WiFiClient/SecurityAnalyzer.swift`
- Detect encryption type: Open, WEP, WPA, WPA2, WPA3
- Flag insecure networks (Open, WEP)
- Check for rogue AP (unusual BSSID for known SSID)
- Certificate validation for enterprise networks

### 3.2 Security Warnings
**File**: `Sources/WiFiClient/SecurityWarningView.swift`
- Visual indicators in network list
- Warning dialog before joining unsafe networks
- Recommendations: "Use VPN on this network"

## Phase 4: Captive Portal Handling

### 4.1 Auto-Fill System
**File**: `Sources/WiFiClient/CaptivePortalDetector.swift`
- Detect captive portal via connectivity check
- Open in embedded web view

**File**: `Sources/WiFiClient/PortalAutoFill.swift`
- Store form field mappings per SSID
- Auto-fill known credentials
- Learn from user input
- Support common patterns (email, phone, terms acceptance)

## Phase 5: Credential Vault

### 5.1 Password Management
**File**: `Sources/WiFiClient/CredentialStore.swift`
- Store all WiFi passwords in Keychain
- Easy viewing/editing interface
- Import from system keychain
- Export (encrypted)

### 5.2 Sharing Features
**File**: `Sources/WiFiClient/CredentialSharing.swift`
- Generate QR code for network credentials
- Generate shareable link (encrypted, expiring)
- Support WiFi QR standard format

**File**: `Sources/WiFiClient/QRCodeView.swift`
- Display QR for scanning
- Scan QR to import credentials

## Phase 6: Advanced Features

### 6.1 Network Heatmap
**File**: `Sources/WiFiClient/HeatmapView.swift`
- Track signal strength by location (CoreLocation)
- Visualize coverage in floor plan
- Export data

### 6.2 Network Database
**File**: `Sources/WiFiClient/NetworkDatabase.swift`
- Crowdsourced free WiFi locations
- Integration with Maps
- User contributions
- Privacy-preserving location data

### 6.3 VPN Integration
**File**: `Sources/WiFiClient/VPNManager.swift`
- Auto-enable VPN on untrusted networks
- Support system VPN configurations
- Quick toggle in menu bar

## Implementation Order

### MVP (Weeks 1-2)
1. Basic menu bar app with current network display
2. Network scanning and manual connect
3. Simple priority list with auto-join
4. Connection status and error explanations

### V1.0 (Weeks 3-4)
5. Speed monitoring and notifications
6. Historical speed tracking
7. Security warnings
8. Basic credential vault

### V1.1 (Weeks 5-6)
9. Captive portal auto-fill
10. QR code sharing
11. Enhanced UI with graphs

### V2.0 (Future)
12. Heatmap functionality
13. Network database integration
14. VPN features

## Technical Notes

### CoreWLAN API
- Requires location permission on macOS
- No sandbox for full functionality
- CWWiFiClient for scanning/connecting
- Notifications for network changes

### Performance
- Minimize battery impact: limit scanning frequency
- Background speed tests only on AC power (optional)
- Efficient data storage with pruning

### Privacy
- All data stored locally
- Optional cloud sync (encrypted)
- Clear data retention policies

### Testing
- Unit tests for business logic
- Integration tests with mock WiFi
- Manual testing on various networks

## File Structure

**Actual Files (Currently Implemented):**
```
wifiClient/
├── wifiClientApp.swift           # Entry point ✓
├── WiFiState.swift               # Shared state ✓
├── WiFiManager.swift             # CoreWLAN wrapper ✓
├── MenuBarView.swift             # Menu bar UI ✓
├── AutoJoinEngine.swift          # Basic auto-join (incomplete) ✓
├── NetworkPriority.swift         # Preferences storage (simple) ✓
├── LocationManager.swift         # Location permissions ✓
└── ContentView.swift             # (unused placeholder)
```

**Planned Files (Still TODO):**
```
wifiClient/
├── ConnectionStrategy.swift      # Connection logic
├── ConnectionStatusView.swift    # Progress UI
├── SpeedMonitor.swift            # Speed tracking
├── SpeedTest.swift               # Speed test impl
├── NotificationManager.swift     # Alert system
├── SpeedGraphView.swift          # Visualization
├── SecurityAnalyzer.swift        # Security checks
├── SecurityWarningView.swift     # Security UI
├── CaptivePortalDetector.swift   # Portal detection
├── PortalAutoFill.swift          # Portal automation
├── CredentialStore.swift         # Keychain wrapper
├── CredentialSharing.swift       # Sharing logic
├── QRCodeView.swift              # QR generation
├── PreferencesWindow.swift       # Settings UI
└── Models/
    ├── NetworkPriority.swift     # Priority model (needs expansion)
    ├── SpeedData.swift           # Speed metrics
    └── SecurityInfo.swift        # Security data
```

## Implementation Status

### ✅ COMPLETED (Basic MVP)

**Basic Infrastructure**
- ✓ WiFiManager - CoreWLAN wrapper for scanning and connecting
- ✓ WiFiState - Observable state management
- ✓ MenuBarView - Basic menu bar UI with network list
- ✓ LocationManager - Location permissions for WiFi scanning
- ✓ NetworkPrefs - Simple auto-connect preferences (UserDefaults)
- ✓ AutoJoinEngine - Basic auto-join logic (signal strength only)

**Working Features**
- ✓ Network scanning every 10 seconds
- ✓ Display available networks with signal strength
- ✓ Toggle auto-connect per network (checkmark UI)
- ✓ Basic auto-join attempts every 15 seconds
- ✓ Current network display
- ✓ Manual network connection

### 🚧 TODO - Phase 1: Complete Auto-Join Management

**Missing from Phase 1**
- ❌ Priority levels (High/Medium/Low/Never) - only has boolean auto-connect
- ❌ Manual ordering within priority groups
- ❌ Blacklist functionality
- ❌ Smart switching based on historical speed (only uses signal)
- ❌ Connection progress/status tracking
- ❌ Error explanations with actionable advice
- ❌ Proper ConnectionStrategy.swift (logic is mixed into AutoJoinEngine)
- ❌ ConnectionStatusView.swift for progress UI

### 🚧 TODO - Phase 2: Monitoring & Notifications

**All of Phase 2 Missing**
- ❌ Speed tracking with SpeedTester
- ❌ Poor connection alerts via NotificationService
- ❌ Historical speed data storage (SQLite)
- ❌ Speed visualization in UI
- ❌ Real-time quality indicators
- ❌ SpeedMonitor.swift
- ❌ SpeedTest.swift
- ❌ NotificationManager.swift
- ❌ SpeedGraphView.swift

### 🚧 TODO - Phase 3: Security Analysis

**All of Phase 3 Missing**
- ❌ Security analysis per network (encryption type detection)
- ❌ Visual security warnings
- ❌ Unsafe network alerts
- ❌ SecurityAnalyzer.swift
- ❌ SecurityWarningView.swift
- ❌ SecurityInfo.swift model

### 🚧 TODO - Phase 4: Captive Portal

**All of Phase 4 Missing**
- ❌ Captive portal detection
- ❌ Auto-fill for known portals
- ❌ Learn from user input
- ❌ CaptivePortalDetector.swift
- ❌ PortalAutoFill.swift

### 🚧 TODO - Phase 5: Credential Vault

**All of Phase 5 Missing**
- ❌ Password management UI
- ❌ QR code generation/scanning
- ❌ Secure sharing links
- ❌ CredentialStore.swift
- ❌ CredentialSharing.swift
- ❌ QRCodeView.swift

### 🚧 TODO - Phase 6: Advanced Features

**All of Phase 6 Missing**
- ❌ Network heatmaps
- ❌ Crowdsourced database
- ❌ VPN integration
- ❌ HeatmapView.swift
- ❌ NetworkDatabase.swift
- ❌ VPNManager.swift

## Current Status Summary

**What Works:**
- Basic WiFi scanning and network display
- Simple on/off auto-connect toggle per network
- Automatic reconnection attempts based on signal strength
- Location permission handling

**What's Missing:**
- Everything described in the detailed plan above is still TODO
- The current implementation is a very basic prototype
- Need to complete Phase 1 (priority system, error handling) before moving to Phase 2

## Next Steps
1. Complete Phase 1: Priority system (High/Medium/Low/Never)
2. Add connection progress tracking and error explanations
3. Implement historical speed tracking for smarter network selection
4. Then move to Phase 2: Speed monitoring and notifications
