//
//  ContentView.swift
//  EcoLink
//
//  Created by Shashwath Dinesh on 7/12/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        SignupView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
