//
//  OrientationApp.swift
//  Orientation
//
//  Created by Heliodoro Tejedor Navarro on 12/30/22.
//

import SwiftUI

@main
struct OrientationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        DocumentGroup(newDocument: OrientationDocument()) { file in
            ContentView(document: file.$document)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
