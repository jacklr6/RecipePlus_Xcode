//
//  StepsViewModel.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/19/25.
//

import SwiftUI
import SwiftData

@Model
class StepsViewModel {
    var id = UUID()
    var text: String
    
    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}
