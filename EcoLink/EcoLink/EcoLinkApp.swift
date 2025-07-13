//
//  EcoLinkApp.swift
//  EcoLink
//
//  Created by Shashwath Dinesh on 7/12/25.
//

import SwiftUI

@main
struct EcoLinkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
