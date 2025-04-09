//
//  EditRecipe.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/2/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditRecipe: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var recipe: RecipesViewModel
    @Query private var sections: [SectionsViewModel]
    @Query private var steps: [StepsViewModel]
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @FocusState private var focusedStep: Int?
    @AppStorage("imageCompressionQuality") private var imageCompressionQuality = 0.8
    @AppStorage("isDoneEditing") private var isDoneEditing: Bool = false
    @State private var selectedSection: String = ""
    @State private var showImageAlert: Bool = false
    @State private var showShareAlert: Bool = false
    @AppStorage("recipeConfimedEditVisibility") private var recipeConfimedEditVisibility = 0.0
    @AppStorage("recipeConfirmedEditIcon") private var recipeConfirmedEditIcon: Bool = false
    @AppStorage("primaryColor") private var primaryColor: Int = 4
    @AppStorage("secondaryColor") private var secondaryColor: Int = 5

    let unitOptionsCooking = ["Cup(s)", "Tbsp", "Tspn", "Oz", "Misc"]
    let unitOptionsTime = ["Minutes", "Hours", "Days", "Weeks"]
    let difficultyOptions = ["Easy", "Moderate", "Hard"]

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    HStack {
                        Text("Edit Recipe")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .textSelection(.disabled)
                    .listRowBackground(Color.clear)
                    
                    Section("Basic Information") {
                        HStack {
                            Text("Name:")
                            TextField("Recipe Name", text: $recipe.name)
                        }
                        
                        Picker("Section:", selection: $selectedSection) {
                            ForEach(sections, id: \.name) { section in
                                Text(section.name).tag(section.name)
                            }
                        }
                        .onAppear {
                            selectedSection = recipe.sectionName
                        }
                        .onChange(of: selectedSection) { _, newValue in
                            recipe.sectionName = newValue
                        }
                        
                        if recipe.ingredients.isEmpty {
                            VStack {
                                Text("There was an error in loading your ingredients. Please add the recipe manually.")
                                Text("Error Code: RPER001")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(width: 350)
                        } else {
                            HStack {
                                Text("Total Time:")
                                TextField("Enter Time", text: Binding(
                                    get: { recipe.ingredients.first?.timeAmount ?? "" },
                                    set: { newValue in
                                        if !recipe.ingredients.isEmpty {
                                            recipe.ingredients[0].timeAmount = newValue
                                        }
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                
                                Picker("", selection: Binding(
                                    get: { recipe.ingredients.first?.unitTime ?? "Minutes" },
                                    set: { newValue in
                                        if !recipe.ingredients.isEmpty {
                                            recipe.ingredients[0].unitTime = newValue
                                        }
                                    }
                                )) {
                                    ForEach(unitOptionsTime, id: \.self) { unitTime in
                                        Text(unitTime).tag(unitTime)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            HStack {
                                Text("Difficulty:")
                                Picker("Difficulty:", selection: Binding(
                                    get: { recipe.ingredients.first?.difficulty ?? "Easy" },
                                    set: { newValue in
                                        if !recipe.ingredients.isEmpty {
                                            recipe.ingredients[0].difficulty = newValue
                                        }
                                    }
                                )) {
                                    ForEach(difficultyOptions, id: \.self) { difficulty in
                                        Text(difficulty).tag(difficulty)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                    }
                    
                    Section(header: HStack {
                        Text("Edit Image")
                        Spacer()
                        Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                            .foregroundColor(.blue)
                            .font(.headline)
                            .onTapGesture {
                                showImageAlert = true
                            }
                    }) {
                        HStack {
                            if let image = selectedImage ?? (recipe.imageData != nil ? UIImage(data: recipe.imageData!) : nil) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
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
                    
                    ForEach(recipe.ingredients.indices, id: \.self) { index in
                        Section(header: Text("Ingredient \(index + 1)")) {
                            TextField("Ingredient Name", text: Binding(
                                get: { recipe.ingredients[index].name },
                                set: { newValue in
                                    recipe.ingredients[index].name = newValue
                                }
                            ))
                            
                            HStack {
                                TextField("Quantity", text: Binding(
                                    get: { recipe.ingredients[index].quantity },
                                    set: { newValue in
                                        recipe.ingredients[index].quantity = newValue
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                
                                Picker("Unit:", selection: Binding(
                                    get: { recipe.ingredients[index].unit },
                                    set: { newValue in
                                        recipe.ingredients[index].unit = newValue
                                    }
                                )) {
                                    ForEach(unitOptionsCooking, id: \.self) { unit in
                                        Text(unit).tag(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                    }
                    
                    ForEach(recipe.steps.indices, id: \.self) { index in
                        Section(header: Text("Step \(index + 1)")) {
                            TextEditor(text: Binding(
                                get: { recipe.steps[index].text },
                                set: { newValue in
                                    recipe.steps[index].text = newValue
                                }
                            ))
                                .focused($focusedStep, equals: index)
                                .frame(minHeight: 82, maxHeight: 150)
                                .overlay(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        if recipe.steps[index].text.isEmpty {
                                            Text("Enter Step \(index + 1) Here")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                )
                                .toolbar {
                                    if focusedStep == index {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Button("Insert Timer") {
                                                insertTimer(for: index)
                                            }
                                            Spacer()
                                            Button("Done") {
                                                focusedStep = nil
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    
                    Button(action: {
                        recipe.imageData = selectedImage?.jpegData(compressionQuality: imageCompressionQuality)
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save \(error)")
                        }
                        changesSaved()
                        dismiss()
                    }) {
                        HStack {
                            Text("Save Changes")
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .symbolEffect(.wiggle, options: .speed(0.5))
                        }
                        .fontWeight(.semibold)
                    }
                }
                .alert("Privacy Information", isPresented: $showImageAlert) {
                    Button("OK", role: .cancel) { dismiss() }
                } message: {
                    Text("All photos are stored on-device and never leave your iPhone. Not only your photos, but all of your Recipes+ data can be erased in settings.")
                }
                .alert("Share", isPresented: $showShareAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("The ability to share this recipe with your friends is coming soon. (2.1)")
                }
            }
        }
        .onAppear {
            if let imageData = recipe.imageData {
                selectedImage = UIImage(data: imageData)
            }
        }
    }
    
    private func loadImage(for item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        }
    }
    
    private func changesSaved() {
        recipeConfimedEditVisibility = 1.0
        isDoneEditing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            recipeConfirmedEditIcon = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            recipeConfimedEditVisibility = 0.0
            recipeConfirmedEditIcon = false
            isDoneEditing = false
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
    
    private func insertTimer(for index: Int) {
        steps[index].text += " {TimerName:00:00}"
    }
}

struct EditRecipe_Previews: PreviewProvider {
    static var previews: some View {
        let previewRecipe = RecipesViewModel(name: "Test Recipe", sectionName: "Appetizer", ingredients: [])
        EditRecipe(recipe: previewRecipe)
    }
}
