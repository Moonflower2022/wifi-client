//
//  wifiClientApp.swift
//  wifiClient
//
//  Created by Harrison Qian on 11/7/25.
//

import SwiftUI

@main
struct wifiClientApp: App {
    var body: some Scene {
        MenuBarExtra("WiFi", systemImage: "wifi") {
            MenuBarView()
        }
    }
}
