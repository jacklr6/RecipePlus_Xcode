//
//  RecipePlusApp.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData

@main
struct RecipePlusApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([RecipesViewModel.self, SectionsViewModel.self])
        let container = try! ModelContainer(for: schema)
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
