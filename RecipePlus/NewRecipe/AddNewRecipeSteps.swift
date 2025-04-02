//
//  AddNewRecipeSteps.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData
import TipKit

struct AddNewRecipeSteps: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var recipe: RecipesViewModel

    @State private var numOfSteps: Int = 1
    @FocusState private var focusedStep: Int?
    @State private var showTimerAlert: Bool = false
    @State private var showRequiredQuestionsAlert: Bool = false
    @AppStorage("recipeConfimedSaveVisibility") private var recipeConfimedSaveVisibility = 0.0
    @AppStorage("recipeConfirmedSaveIcon") private var recipeConfirmedSaveIcon: Bool = false
    
    @State private var steps: [StepsViewModel] = []
    
    struct RecipeTimerTip: Tip {
        var title: Text { Text("Add a Timer") }
        var message: Text? { Text("Tap the \(Image(systemName: "info.circle")) to learn more about adding a timer to a recipe!") }
        var image: Image? { Image(systemName: "timer") }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header:
                                HStack {
                                    Text("Number of Steps")
                                    Spacer()
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                        .font(.headline)
                                        .onTapGesture {
                                            showTimerAlert = true
                                        }
                                        .popoverTip(RecipeTimerTip())
                                        .onAppear { try? Tips.configure([]) }
                                },
                            footer: Text("Be descriptive in your instructions as you may forget them later on!")) {
                        Picker("Number of Steps:", selection: $numOfSteps) {
                            ForEach(1...20, id: \.self) { number in
                                Text("\(number)").tag(number)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: numOfSteps) { updateStepsArray() }
                    }

                    ForEach(steps.indices, id: \.self) { index in
                        Section(header: Text("Step \(index + 1)\(Text("*").foregroundColor(.red))")) {
                            TextEditor(text: $steps[index].text)
                                .focused($focusedStep, equals: index)
                                .frame(minHeight: 82, maxHeight: 150)
                                .overlay(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        if steps[index].text.isEmpty {
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
                    
                    Section(footer: Text("Questions with \(Text("*").foregroundColor(.red)) are required")) {
                        Button(action: requiredQuestionFilled) {
                            HStack {
                                Text("Save Recipe")
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .font(.title2)
                                    .symbolEffect(.wiggle, options: .speed(0.5))
                            }
                            .fontWeight(.semibold)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(Color.blue)
                    }
                }
                .alert("Timers", isPresented: $showTimerAlert) {
                    Button("OK", role: .cancel) { dismiss() }
                } message: {
                    Text("To insert a timer, tap 'Insert Timer'. Input the timer information in the format '{TimerName:HH:MM}'.")
                }
                .alert("Required Questions", isPresented: $showRequiredQuestionsAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please fill out the required text fields to continue.")
                }
            }
            .navigationTitle("Add a New Recipe")
            .onAppear {
                updateStepsArray()
            }
        }
    }

    private func insertTimer(for index: Int) {
        steps[index].text += "{TimerName:00:00}"
    }

    private func updateStepsArray() {
        if steps.count < numOfSteps {
            for _ in steps.count..<numOfSteps {
                steps.append(StepsViewModel(text: ""))
            }
        } else if steps.count > numOfSteps {
            steps.removeLast(steps.count - numOfSteps)
        }
    }
    
    private func requiredQuestionFilled() {
        if steps.contains(where: { $0.text.isEmpty }) {
            showRequiredQuestionsAlert = true
        } else {
            saveRecipe()
        }
    }

    private func saveRecipe() {
        recipe.name = recipe.name
        recipe.sectionName = recipe.sectionName
        recipe.ingredients = recipe.ingredients
        recipe.imageData = recipe.imageData
        recipe.saveDate = Date()
        recipe.steps = steps
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving recipe: \(error)")
        }
        
        recipeConfimedSaveVisibility = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            recipeConfirmedSaveIcon = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            recipeConfimedSaveVisibility = 0.0
            recipeConfirmedSaveIcon = false
        }
        
        dismiss()
    }
}

struct AddNewRecipeSteps_Previews: PreviewProvider {
    static var previews: some View {
        AddNewRecipeSteps(recipe: RecipesViewModel(name: "Sample Recipe", sectionName: "Desserts", ingredients: [], steps: []))
    }
}
