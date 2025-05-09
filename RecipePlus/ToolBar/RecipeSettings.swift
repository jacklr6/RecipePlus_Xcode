//
//  RecipeSettings.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData
import TipKit
import HomeKit

struct RecipeSettings: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var settingsEditorIsPresented: Bool = false
    @State private var settingsStepCounterIsPresented: Bool = false
    @State private var deleteConfirmation: Bool = false
    @State private var isDeleting: Bool = false
    @State private var dataIsDeleted: Bool = false
    @AppStorage("primaryColor") private var primaryColor: Int = 4
    @AppStorage("secondaryColor") private var secondaryColor: Int = 5
    
    @State private var sections: [SectionsViewModel] = []
    @State private var recipes: [RecipesViewModel] = []
    @State private var ingredients: [IngredViewModel] = []
    @State private var steps: [StepsViewModel] = []
    
    @State private var appColorScheme: ColorScheme?
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("isLightMode") private var isLightMode: Bool = true
    @State private var isEditing = false
    @AppStorage("imageCompressionQuality") private var imageCompressionQuality = 0.8
    @AppStorage("TimeIntervalSave") var timeIntervalSave: String = "10"
    @AppStorage("stepCounterPreference") private var stepCounterPreference = 0

    var body: some View {
        NavigationStack {
            VStack {
                if isDeleting {
                    ProgressView("Deleting...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Form {
                        Section(header: Text("Display Mode"), footer: Text("Choose to use Dark Mode, or Light Mode")) {
                            Toggle("Light Mode", systemImage: isLightMode ? "sun.max.fill" : "sun.min", isOn: $isLightMode)
                                .onChange(of: isLightMode) { _, newValue in
                                    if newValue {
                                        isDarkMode = false
                                        appColorScheme = .light
                                    }
                                    else {
                                        isDarkMode = true
                                        appColorScheme = .dark
                                    }
                                }
                                .symbolEffect(.bounce, options: .repeat(1))
                                .contentTransition(.symbolEffect(.replace))
                                .tint(Color.blue)
                            
                            Toggle("Dark Mode", systemImage: isDarkMode ? "moon.circle.fill" : "moon.circle", isOn: $isDarkMode)
                                .onChange(of: isDarkMode) { _, newValue in
                                    if newValue {
                                        isLightMode = false
                                        appColorScheme = .dark
                                    }
                                    else {
                                        isLightMode = true
                                        appColorScheme = .light
                                    }
                                }
                                .symbolEffect(.bounce, options: .repeat(1))
                                .contentTransition(.symbolEffect(.replace))
                                .tint(Color.blue)
                        }
                        
                        Section(header: Text("Sections"), footer: Text("Create, edit, and delete sections here.")) {
                            HStack {
                                Button(action: {
                                    loadSections()
                                    settingsEditorIsPresented.toggle()
                                }) {
                                    Text("Show Sections Editor")
                                }
                                .sheet(isPresented: $settingsEditorIsPresented) {
                                    SectionsEditorView(sections: sections)
                                }
                                Spacer()
                                Image(systemName: "line.3.horizontal")
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        
                        Section(header: Text("Image Compression \(Image(systemName: "photo.on.rectangle.angled"))  |  \(String(format: "%.1f", imageCompressionQuality))"),
                                footer: Text("Change the quality of images when they are saved to your Recipe+ list.")) {
                            Slider(value: $imageCompressionQuality, in: 0.0...1.0, step: 0.1) {
                            } minimumValueLabel: {
                                Text("Low ")
                                    .foregroundColor(imageCompressionQuality == 0.0 ? .blue : .black)
                            } maximumValueLabel: {
                                Text(" High")
                                    .foregroundColor(imageCompressionQuality == 1.0 ? .blue : .black)
                            } onEditingChanged: { editing in
                                isEditing = editing
                            }
                        }
                        
                        Section(header: Text("App Color \(Image(systemName: "paintbrush"))").foregroundStyle(LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)), footer: Text("Changes the colors of certain icons in the app.")) {
                            HStack {
                                Picker("Primary Color", selection: $primaryColor) {
                                    Text("Red").tag(1)
                                    Text("Orange").tag(2)
                                    Text("Yellow").tag(3)
                                    Text("Green").tag(4)
                                    Text("Blue").tag(5)
                                    Text("Purple").tag(6)
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 150)
                                
                                Divider()
                                    .frame(width: 1.5, height: 120)
                                    .background(Color.black.opacity(0.15))
                                
                                Picker("Primary Color", selection: $secondaryColor) {
                                    Text("Red").tag(1)
                                    Text("Orange").tag(2)
                                    Text("Yellow").tag(3)
                                    Text("Green").tag(4)
                                    Text("Blue").tag(5)
                                    Text("Purple").tag(6)
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 150)
                            }
                        }
                        
                        Section(header: Text("Step Counter"), footer: Text("Gives you an option for which steps counter you prefer to use in CookingUI.")) {
                            HStack {
                                Button(action: {
                                    settingsStepCounterIsPresented.toggle()
                                }) {
                                    Text("Show Step Counters")
                                }
                                .sheet(isPresented: $settingsStepCounterIsPresented) {
                                    CookingStepsPreference()
                                }
                                Spacer()
                                Image(systemName: stepCounterPreference == 0 ? "circle.grid.2x1.left.filled" : "circle.grid.2x1.right.filled")
                                    .foregroundColor(Color.blue)
                            }
                        }
                        
                        Section(header: Text("Time Interval"), footer: Text("Change the amount of time before the arrow pops up in CookingUI. A value of 0 will result in the arrow never popping up.")) {
                            HStack {
                                Text("Time Interval:")
                                Spacer()
                                TextField("10", text: $timeIntervalSave)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.blue)
                                Text("Seconds")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Section(header: Text("Your Data")) {
                            Button(action: {
                                deleteConfirmation = true
                            }) {
                                HStack {
                                    Text("Delete All Recipe+ Data")
                                    Spacer()
                                    Image(systemName: "trash")
                                }
                                .foregroundColor(Color.red)
                                .fontWeight(.semibold)
                            }
                        }
                        
                        VStack {
                            Text("Recipe + | iOS Build \(Text("2.0.4 Beta").fontWeight(.bold).foregroundStyle(LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)))")
                            Text("Jack Rogers | 2025")
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .textSelection(.disabled)
                        .listRowBackground(Color.clear)
                    }
                    .navigationTitle("Settings")
                    .navigationBarItems(leading: Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            Text("Recipe+")
                        }
                    })
                    .alert("Confirmation", isPresented: $deleteConfirmation) {
                        Button("Delete", role: .destructive) { deleteAllRecipes() }
                        Button("Cancel", role: .cancel) { dismiss() }
                    } message: {
                        Text("Are you sure you want to remove all of your Recipe+ data?\nThis action cannot be undone.")
                    }
                    .alert("Your Data Has Been Deleted", isPresented: $dataIsDeleted) {
                        Button("Cool!", role: .cancel) { dismiss() }
                    } message: {
                        Text("All of your data has been removed. Welcome to Recipe+.")
                    }
                }
            }
        }
        .preferredColorScheme(appColorScheme)
    }

    private func loadSections() {
        let fetchDescriptor = FetchDescriptor<SectionsViewModel>()
        sections = (try? modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    func deleteAllRecipes() {
        isDeleting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let sectionsFetch = FetchDescriptor<SectionsViewModel>()
            if let fetchedSections = try? modelContext.fetch(sectionsFetch) {
                for section in fetchedSections {
                    modelContext.delete(section)
                }
            }

            let recipesFetch = FetchDescriptor<RecipesViewModel>()
            if let fetchedRecipes = try? modelContext.fetch(recipesFetch) {
                for recipe in fetchedRecipes {
                    modelContext.delete(recipe)
                }
            }

            let ingredientsFetch = FetchDescriptor<IngredViewModel>()
            if let fetchedIngredients = try? modelContext.fetch(ingredientsFetch) {
                for ingredient in fetchedIngredients {
                    modelContext.delete(ingredient)
                }
            }

            let stepsFetch = FetchDescriptor<StepsViewModel>()
            if let fetchedSteps = try? modelContext.fetch(stepsFetch) {
                for step in fetchedSteps {
                    modelContext.delete(step)
                }
            }

            do {
                try modelContext.save()
            } catch {
                print("Failed to delete data: \(error)")
            }

            sections.removeAll()
            recipes.removeAll()
            ingredients.removeAll()
            steps.removeAll()
            deleteConfirmation = false
            isDeleting = false
            dataIsDeleted = true
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

struct SectionsEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State var sections: [SectionsViewModel]
    
    @State private var selectedColorScheme: ColorScheme?
    @AppStorage("primaryColor") private var primaryColor: Int = 4
    @AppStorage("secondaryColor") private var secondaryColor: Int = 5

    var body: some View {
        NavigationStack {
            VStack {
                if sections.isEmpty {
                    VStack {
                        Image(systemName: "square.3.layers.3d")
                            .font(.largeTitle)
                            .foregroundStyle(
                                LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .padding(.bottom, 5)
                        Text("No Sections Yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Add a section in the bottom left corner to start creating and editing sections.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                } else {
                    List {
                        ForEach($sections, id: \.id) { $section in
                            TextField("Section Name", text: $section.name)
                        }
                        .onDelete { indexSet in
                            sections.remove(atOffsets: indexSet)
                        }
                        .onMove { source, destination in
                            sections.move(fromOffsets: source, toOffset: destination)
                        }
                        
                        Text("Uncategorized")
                    }
                }
            }
            .onAppear {
                loadSections()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        saveSections()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        let newSection = SectionsViewModel(id: UUID(), name: "New Section")
                        sections.append(newSection)
                    }) {
                        Label("Add Section", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Edit Sections")
        }
        .preferredColorScheme(selectedColorScheme)
    }
    
    private func loadSections() {
        let fetchDescriptor = FetchDescriptor<SectionsViewModel>()
        sections = (try? modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    private func saveSections() {
        let fetchDescriptor = FetchDescriptor<SectionsViewModel>()
        let existingSections = (try? modelContext.fetch(fetchDescriptor)) ?? []
        
        for section in sections {
            if let existingSection = existingSections.first(where: { $0.id == section.id }) {
                existingSection.name = section.name
            } else {
                let newSection = SectionsViewModel(id: section.id, name: section.name)
                modelContext.insert(newSection)
            }
        }
        
        try? modelContext.save()
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

struct CookingStepsPreference: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("stepCounterPreference") private var stepCounterPreference = 0
    @State private var stepCounter = 1
    @State private var showGauge = true
    @State private var showInfoText = false
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack {
                        Image(systemName: stepCounterPreference == 1 ? "checkmark" : "xmark")
                            .font(.system(size: stepCounterPreference == 1 ? 25 : 20, weight: .semibold))
                            .foregroundColor(stepCounterPreference == 1 ? Color.green : Color.black)
                            .contentTransition(.symbolEffect(.replace))
                            .offset(y: -9)
                        
                        Image(systemName: "\(stepCounter).circle")
                            .font(.system(size: 40))
                            .foregroundColor(Color.blue)
                            .contentTransition(.symbolEffect(.replace))
                            .onTapGesture {
                                stepCounterPreference = 1
                            }
                    }
                    .padding(.trailing, 7)
                    
                    Divider()
                        .frame(height: 130)
                    
                    VStack {
                        Image(systemName: stepCounterPreference == 1 ? "xmark" : "checkmark")
                            .font(.system(size: stepCounterPreference == 0 ? 25 : 20, weight: .semibold))
                            .foregroundColor(stepCounterPreference == 0 ? Color.green : Color.black)
                            .contentTransition(.symbolEffect(.replace))
                        
                        Gauge(value: Double(stepCounter), in: 0...50) {
                        } currentValueLabel: {
                            Text("\(stepCounter)")
                                .foregroundColor(.blue)
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(.blue)
                        .scaleEffect(x: 0.72, y: 0.72)
                        .opacity(showGauge ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showGauge)
                        .onTapGesture {
                            stepCounterPreference = 0
                        }
                    }
                }
                .padding(.bottom, 15)
                
                Button(action: {
                    if stepCounter < 50 {
                        showGauge = false
                        stepCounter += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showGauge = true
                        }
                    }
                }) {
                    Text("Add One")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .shadow(color: .blue, radius: 10, y: 0)
                
                Button(action: {
                    stepCounter = 1
                }) {
                    Text("Reset")
                }
                .padding(.top, 5)
                .opacity(stepCounter > 1 ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: stepCounter)
                
                Text("The animation won't be noticable if you're moving between steps.")
                    .font(.callout)
                    .frame(width: 300)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .opacity(showInfoText ? 1 : 0)
                    .padding(.top, 5)
                    .animation(.easeInOut(duration: 0.3), value: showInfoText)
            }
            .onAppear {
                showInfo()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
        }
    }
    
    func showInfo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showInfoText = true
        }
    }
}

struct RecipeSettings_Previews: PreviewProvider {
    static var previews: some View {
//        RecipeSettings()
        CookingStepsPreference()
    }
}
