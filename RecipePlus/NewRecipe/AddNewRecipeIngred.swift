//
//  AddNewRecipeIngred.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData
import TipKit
import PhotosUI

struct NoSectionsTip: Tip {
    var title: Text { Text("No Sections Found") }
    var message: Text? { Text("Navigate to Settings to create recipe sections.") }
    var image: Image? { Image(systemName: "gear") }
}

struct AddNewRecipeIngred: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var recipeName: String = ""
    @State private var showImageAlert = false
    @State private var numOfIngred: Int = 1
    @State private var ingredients: [IngredViewModel] = [IngredViewModel(name: "", timeAmount: "", unitTime: "Minutes", difficulty: "", quantity: "", unit: "Cup(s)")]
    @State private var isExpanded = false
    @State private var searchTerm = "Uncategorized"
    @State private var navigateToSteps = false
    @State private var showRequiredQuestionsAlert: Bool = false
    @State private var recipeCreateDate = Date()
    @State private var imageConfimedUploadVisibility = 0.0
    @State private var imageConfirmedIcon: Bool = false
    @Query private var sections: [SectionsViewModel] = [SectionsViewModel(name: "Appetizer")]
    @State private var steps: [StepsViewModel] = [StepsViewModel(text: "Step 1")]
    @State private var selectedRecipe: RecipesViewModel?
    
    @AppStorage("imageCompressionQuality") private var imageCompressionQuality = 0.8
    @AppStorage("primaryColor") private var primaryColor: Int = 4
    @AppStorage("secondaryColor") private var secondaryColor: Int = 5
    
    let unitOptionsCooking = ["Cup(s)", "Tbsp", "Tspn", "Oz", "Misc"]
    let unitOptionsTime = ["Minutes", "Hours", "Days", "Weeks"]
    let difficultyOptions = ["Easy", "Moderate", "Hard"]
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    init() {
        try? Tips.configure()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        Section("Basic Information") {
                            HStack {
                                Text("Name:\(Text("*").foregroundColor(.red))")
                                TextField("Recipe Name", text: $recipeName)
                            }
                            
                            Picker("Section:", selection: $searchTerm) {
                                Text("Uncategorized").tag("Uncategorized")
                                ForEach(sections, id: \.name) { section in
                                    Text(section.name).tag(section.name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .popoverTip(NoSectionsTip())
                            .onAppear { try? Tips.configure([]) }
                            
                            HStack {
                                Text("Total Time:\(Text("*").foregroundColor(.red))")
                                TextField("Enter Time", text: $ingredients[0].timeAmount)
                                    .keyboardType(.decimalPad)
                                Picker("", selection: $ingredients[0].unitTime) {
                                    ForEach(unitOptionsTime, id: \..self) { unitTime in
                                        Text(unitTime).tag(unitTime)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding(.top, -1)
                            
                            HStack {
                                Text("Difficulty:")
                                Picker("Difficulty:", selection: $ingredients[0].difficulty) {
                                    ForEach(difficultyOptions, id: \..self) { difficulty in
                                        Text(difficulty).tag(difficulty)
                                    }
                                }
                                .padding(.trailing, -5)
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            Picker("Number of Ingredients:", selection: $numOfIngred) {
                                ForEach(1...12, id: \..self) { number in
                                    Text("\(number)").tag(number)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: numOfIngred, initial: false) { oldValue, newValue in
                                if newValue > oldValue {
                                    for _ in 0..<(newValue - oldValue) {
                                        ingredients.append(IngredViewModel(name: "", timeAmount: "", unitTime: "", difficulty: "", quantity: "", unit: "Cup(s)"))
                                    }
                                } else if newValue < oldValue {
                                    ingredients.removeLast(oldValue - newValue)
                                }
                            }
                        }
                        
                        Section(header: HStack {
                            Text("Add an Image")
                            Spacer()
                            Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                                .foregroundColor(.blue)
                                .font(.headline)
                                .onTapGesture {
                                    showImageAlert = true
                                }
                        }) {
                            HStack {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: 150, maxHeight: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 150, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            Image(systemName: "plus.circle")
                                                .foregroundStyle(
                                                    LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                )
                                                .font(.system(size: 40))
                                                .fontWeight(.semibold)
                                        )
                                }
                                Spacer()
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    Label("Choose Photo", systemImage: "photo.on.rectangle.angled")
                                }
                                .onChange(of: selectedPhotoItem) { _, newItem in
                                    if let newItem {
                                        loadImage(for: newItem)
                                    }
                                }
                            }
                        }
                        
                        ForEach(0..<ingredients.count, id: \..self) { index in
                            Section(header: Text("Ingredient \(index + 1)")) {
                                HStack {
                                    Text("Ingredient Name:\(Text("*").foregroundColor(.red))")
                                    TextField("Name", text: $ingredients[index].name)
                                }
                                HStack {
                                    Text("Quantity:\(Text("*").foregroundColor(.red))")
                                    TextField("Number", text: $ingredients[index].quantity)
                                        .padding(.trailing, -30)
                                        .keyboardType(.decimalPad)
                                    Picker("Unit:", selection: $ingredients[index].unit) {
                                        ForEach(unitOptionsCooking, id: \..self) { unit in
                                            Text(unit).tag(unit)
                                        }
                                    }
                                    .padding(.leading, -10)
                                    .pickerStyle(MenuPickerStyle())
                                }
                                .padding(.top, 0)
                            }
                        }
                        
                        Section(footer: Text("Questions with \(Text("*").foregroundColor(.red)) are required")) {
                            Button(action: {
                                let sectionName = searchTerm.isEmpty ? "Uncategorized" : searchTerm
                                
                                if !sections.contains(where: { $0.name == searchTerm }) && !searchTerm.isEmpty {
                                    let newSection = SectionsViewModel(name: searchTerm)
                                    modelContext.insert(newSection)
                                }
                                
                                let imageData = selectedImage?.jpegData(compressionQuality: imageCompressionQuality)
                                
                                let savedIngredients = ingredients.map { ingred in
                                    let newIngred = IngredViewModel(
                                        name: ingred.name,
                                        timeAmount: ingred.timeAmount,
                                        unitTime: ingred.unitTime,
                                        difficulty: ingred.difficulty,
                                        quantity: ingred.quantity,
                                        unit: ingred.unit
                                    )
                                    modelContext.insert(newIngred)
                                    return newIngred
                                }

                                let savedSteps = steps.map { step in
                                    let newStep = StepsViewModel(text: step.text)
                                    modelContext.insert(newStep)
                                    return newStep
                                }
                                
                                let newRecipe = RecipesViewModel(
                                    name: recipeName,
                                    sectionName: sectionName,
                                    ingredients: savedIngredients,
                                    steps: savedSteps,
                                    imageData: imageData,
                                    saveDate: recipeCreateDate
                                )
                                
                                modelContext.insert(newRecipe)
                                
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Error saving new recipe: \(error)")
                                }
                                
                                let descriptor = FetchDescriptor<RecipesViewModel>(
                                    predicate: #Predicate { $0.name == recipeName },
                                    sortBy: [.init(\.saveDate, order: .reverse)]
                                )

                                if let savedRecipe = try? modelContext.fetch(descriptor).first {
                                    selectedRecipe = savedRecipe
                                    navigateToSteps = true
                                }
                                
                                requiredQuestionsFilled()
                            }) {
                                HStack {
                                    Text("Continue to Add Steps")
                                    Spacer()
                                    Image(systemName: "chevron.right.circle")
                                        .font(.title2)
                                        .symbolEffect(.wiggle, options: .speed(0.5))
                                }
                                .fontWeight(.semibold)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(Color.blue)
                            .navigationDestination(isPresented: $navigateToSteps) {
                                if let recipe = selectedRecipe {
                                    AddNewRecipeSteps(recipe: recipe)
                                }
                            }
                        }
                    }
                    .alert("More Information", isPresented: $showImageAlert) {
                        Button("Cool!", role: .cancel) { }
                    } message: {
                        Text("All photos are stored on-device and never leave your iPhone. Not only your photos, but all of your Recipes+ data can be erased in settings.")
                    }
                    .alert("Required Questions", isPresented: $showRequiredQuestionsAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Please fill out the required text fields to continue.")
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack {
                            Image(systemName: imageConfirmedIcon ? "photo.badge.checkmark" : "photo")
                                .font(.system(size: 32))
                                .padding(.trailing, 7)
                                .padding(.top, 5)
                                .contentTransition(.symbolEffect(.replace))
                            Text("Image successfully imported!")
                        }
                        .padding(10)
                        .frame(width: 250, height: 70)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .scaleEffect(imageConfimedUploadVisibility)
                        .opacity(imageConfimedUploadVisibility)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: imageConfimedUploadVisibility)
                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Add New Recipe")
    }
    
    private func loadImage(for item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                changeImageVisibility()
            }
        }
    }

    func changeImageVisibility() {
        imageConfimedUploadVisibility = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            imageConfirmedIcon = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            imageConfimedUploadVisibility = 0.0
            imageConfirmedIcon = false
        }
    }
    
    private func requiredQuestionsFilled() {
        if recipeName.isEmpty {
            showRequiredQuestionsAlert = true
        } else {
            if ingredients[0].timeAmount.isEmpty {
                showRequiredQuestionsAlert = true
            } else {
                if ingredients.contains(where: { $0.name.isEmpty }) {
                    showRequiredQuestionsAlert = true
                } else {
                    if ingredients.contains(where: { $0.quantity.isEmpty }) {
                        showRequiredQuestionsAlert = true
                    } else {
                        navigateToSteps = true
                    }
                }
            }
        }
    }
    
    func colorFromTag(_ tag: Int) -> Color {
        switch tag {
            case 1: return .red
            case 2: return .orange
            case 3: return .yellow
            case 4: return .green
            case 5: return .blue
            case 6: return .purple
            default: return .gray
        }
    }
}

struct AddNewRecipeIngred_Previews: PreviewProvider {
    static var previews: some View {
        AddNewRecipeIngred()
    }
}
