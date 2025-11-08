import SwiftUI
import CoreWLAN

struct MenuBarView: View {
    @State private var state = WiFiState()
    @State private var autoJoin: AutoJoinEngine?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let current = state.currentNetwork {
                Text("Connected: \(current)")
                    .font(.headline)
                Divider()
            }

            if !state.hasLocationPermission {
                Text("Need location permission for WiFi")
                    .foregroundColor(.orange)
                Button("Grant Permission") {
                    LocationManager.shared.requestAuth()
                }
                Divider()
            }

            if state.networks.isEmpty && state.hasLocationPermission {
                Text("No networks found")
                    .foregroundColor(.gray)
            }

            ForEach(state.networks, id: \.self) { network in
                NetworkRow(network: network, state: $state)
            }

            Divider()
            Button("Refresh") { state.refresh() }
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
        .padding()
        .frame(width: 350)
        .onAppear {
            let engine = AutoJoinEngine(state: state)
            autoJoin = engine
            Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
                engine.autoJoinIfNeeded()
            }
        }
    }
}

struct NetworkRow: View {
    let network: CWNetwork
    @Binding var state: WiFiState

    var isAutoConnect: Bool {
        state.prefs.shouldAutoConnect(to: network.ssid!)
    }

    var body: some View {
        Button(action: toggleAutoConnect) {
            HStack(spacing: 8) {
                Text(network.ssid!)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                Spacer()
                Text(signalIcon)
                    .foregroundColor(.primary)
                Image(systemName: isAutoConnect ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isAutoConnect ? .green : .gray)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }

    var signalIcon: String {
        network.rssiValue > -60 ? "📶" : network.rssiValue > -70 ? "📶" : "📉"
    }

    func toggleAutoConnect() {
        let newValue = !isAutoConnect
        state.prefs.setAutoConnect(newValue, for: network.ssid!)
        state.prefs.save()

        if newValue {
            print("Auto-connect enabled for \(network.ssid!), attempting to connect...")
            state.connect(to: network)
        }
    }
}
