//
//  RecipesViewModel.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData

@Model
class RecipesViewModel {
    var name: String
    var isFavorite: Bool
    var sectionName: String
    var ingredients: [IngredViewModel]
    var steps: [StepsViewModel]
    var imageData: Data?
    var saveDate: Date
    
    init(name: String, isFavorite: Bool = false, sectionName: String, ingredients: [IngredViewModel] = [], steps: [StepsViewModel] = [], imageData: Data? = nil, saveDate: Date = Date()) {
        self.name = name
        self.isFavorite = isFavorite
        self.sectionName = sectionName
        self.ingredients = ingredients
        self.steps = steps
        self.imageData = imageData
        self.saveDate = saveDate
    }
}
