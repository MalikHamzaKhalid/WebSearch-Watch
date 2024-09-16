//
//  WatchOS_biltzApp.swift
//  WatchOS-biltz Watch App
//
//  Created by Sheraz Hussain on 27/08/2024.
//

import SwiftUI

@main
struct WatchOS_biltz_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Handle version update and credit initialization when the app launches
                    VersionManager.shared.handleVersionUpdate()
                }
        }
    }
}
