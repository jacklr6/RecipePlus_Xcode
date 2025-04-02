//
//  IngredViewModel.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/2/25.
//

import SwiftUI
import SwiftData
import PhotosUI

@Model
class IngredViewModel {
    var name: String
    var timeAmount: String
    var unitTime: String
    var difficulty: String
    var quantity: String
    var unit: String
    
    init(name: String, timeAmount: String, unitTime: String, difficulty: String, quantity: String, unit: String) {
        self.name = name
        self.timeAmount = timeAmount
        self.unitTime = unitTime
        self.difficulty = difficulty
        self.quantity = quantity
        self.unit = unit
    }
}

