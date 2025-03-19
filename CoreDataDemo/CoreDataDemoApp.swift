//
//  CoreDataDemoApp.swift
//  CoreDataDemo
//
//  Created by Alina Nicorescu on 11.03.2025.
//

import SwiftUI

@main
struct CoreDataDemoApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
