import SwiftUI
import CoreWLAN

struct MenuBarView: View {
    @State private var state = WiFiState()
    @State private var autoJoin: AutoJoinEngine?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HeaderView(state: state)

                if !state.hasLocationPermission {
                    PermissionView()
                } else if state.networks.isEmpty {
                    Text("No networks found").foregroundColor(.gray)
                } else {
                    NetworksGroupedView(state: $state)
                }

                Divider()
                FooterView(state: $state)
            }
            .padding()
        }
        .frame(width: 400, maxHeight: 600)
        .onAppear {
            let engine = AutoJoinEngine(state: state)
            autoJoin = engine
            Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                engine.autoJoinIfNeeded()
            }
        }
    }
}

struct HeaderView: View {
    let state: WiFiState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let current = state.currentNetwork {
                Text("Connected: \(current)").font(.headline)
            }

            if let msg = state.connectionStatus.statusMessage {
                HStack {
                    Text(msg).font(.caption).foregroundColor(.blue)
                    if state.connectionStatus.state is ConnectionState {
                        ProgressView().controlSize(.small)
                    }
                }
            }

            if let advice = state.connectionStatus.advice {
                Text(advice).font(.caption).foregroundColor(.orange)
            }
        }
        Divider()
    }
}

struct PermissionView: View {
    var body: some View {
        Text("Need location permission for WiFi").foregroundColor(.orange)
        Button("Grant Permission") { LocationManager.shared.requestAuth() }
        Divider()
    }
}

struct NetworksGroupedView: View {
    @Binding var state: WiFiState

    var body: some View {
        ForEach([Priority.high, .medium, .low, .never], id: \.self) { pri in
            let nets = networksFor(priority: pri)
            if !nets.isEmpty {
                PrioritySection(priority: pri, networks: nets, state: $state)
            }
        }
    }

    func networksFor(priority: Priority) -> [CWNetwork] {
        let ssids = state.prefs.orderedNetworks(
            for: priority,
            in: state.networks.compactMap { $0.ssid }
        )
        return ssids.compactMap { ssid in
            state.networks.first { $0.ssid == ssid }
        }
    }
}

struct PrioritySection: View {
    let priority: Priority
    let networks: [CWNetwork]
    @Binding var state: WiFiState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(priority.label).font(.caption).foregroundColor(.gray)
            ForEach(Array(networks.enumerated()), id: \.1) { idx, net in
                NetworkRow(
                    network: net,
                    priority: priority,
                    canMoveUp: idx > 0,
                    canMoveDown: idx < networks.count - 1,
                    state: $state
                )
            }
        }
    }
}

struct NetworkRow: View {
    let network: CWNetwork
    let priority: Priority
    let canMoveUp: Bool
    let canMoveDown: Bool
    @Binding var state: WiFiState
    @State private var showMenu = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: { state.connect(to: network) }) {
                HStack {
                    Text(network.ssid!).font(.system(size: 13))
                    Spacer()
                    Text(signalPercent).font(.caption).foregroundColor(.gray)
                }
            }
            .buttonStyle(.plain)

            Menu {
                ForEach(Priority.allCases, id: \.self) { pri in
                    Button(pri.label) {
                        state.prefs.setPriority(pri, for: network.ssid!)
                        state.prefs.save()
                    }
                }
                Divider()
                Button("Move Up") { moveUp() }.disabled(!canMoveUp)
                Button("Move Down") { moveDown() }.disabled(!canMoveDown)
            } label: {
                Image(systemName: "ellipsis.circle").foregroundColor(.gray)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 20)
        }
        .padding(.vertical, 2)
    }

    var signalPercent: String {
        let percent = max(0, min(100, (network.rssiValue + 100) * 2))
        return "\(percent)%"
    }

    func moveUp() {
        state.prefs.moveUp(network.ssid!, in: priority)
        state.prefs.save()
    }

    func moveDown() {
        state.prefs.moveDown(network.ssid!, in: priority)
        state.prefs.save()
    }
}

struct FooterView: View {
    @Binding var state: WiFiState

    var body: some View {
        VStack(spacing: 4) {
            Toggle("Auto-Join", isOn: Binding(
                get: { state.prefs.autoJoinEnabled },
                set: { state.prefs.autoJoinEnabled = $0; state.prefs.save() }
            ))
            HStack {
                Button("Refresh") { state.refresh() }
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
        }
    }
}
