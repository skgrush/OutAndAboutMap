//
//  OutAndAboutMapApp.swift
//  WatchMap Extension
//
//  Created by Samuel Grush on 11/26/20.
//

import SwiftUI

@main
struct OutAndAboutMapApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
