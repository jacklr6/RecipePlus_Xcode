//
//  SectionsViewModel.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData

@Model
class SectionsViewModel {
    var id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
