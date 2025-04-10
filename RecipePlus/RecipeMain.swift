//
//  RecipeMain.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData
import TipKit
import PhotosUI

struct CreateRecipeTip: Tip {
    var title: Text { Text("Add A Recipe") }
    var message: Text? { Text("Tap the plus to add a new recipe to your collection!") }
    var image: Image? { Image(systemName: "cart.badge.plus") }
}

struct RecipeMain: View {
    @State private var selectedTab = 2
    @AppStorage("showSettings") private var showSettings: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [RecipesViewModel]
    @Query private var sections: [SectionsViewModel]
    @Query private var ingredients: [IngredViewModel]
    @Query private var steps: [StepsViewModel]
    
    @State private var selectedRecipeEdit: RecipesViewModel?
    @State private var isEditing: Bool = false
    @AppStorage("isDoneEditing") private var isDoneEditing: Bool = false
    @State private var selectedRecipeCooking: RecipesViewModel?
    @State private var isCooking: Bool = false
    @State private var rotatingSymbol = 0
    @State private var timer: Timer? = nil
    private let symbols = ["stove", "flame", "cooktop", "fork.knife", "frying.pan"]
    @AppStorage("primaryColor") private var primaryColor: Int = 4
    @AppStorage("secondaryColor") private var secondaryColor: Int = 5
    @AppStorage("recipeConfimedSaveVisibility") private var recipeConfimedSaveVisibility = 0.0
    @AppStorage("recipeConfirmedSaveIcon") private var recipeConfirmedSaveIcon: Bool = false
    @AppStorage("recipeConfimedEditVisibility") private var recipeConfimedEditVisibility = 0.0
    @AppStorage("recipeConfirmedEditIcon") private var recipeConfirmedEditIcon: Bool = false
    
    var groupedRecipes: [String: [RecipesViewModel]] {
        Dictionary(grouping: recipes, by: { $0.sectionName })
    }
    
    init() {
        try? Tips.configure()
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                RecipeFavorites()
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Favorites")
                    }.tag(1)
                
                NavigationStack {
                    ZStack {
                        VStack {
                            if recipes.isEmpty {
                                VStack {
                                    Image(systemName: symbols[rotatingSymbol])
                                        .font(.largeTitle)
                                        .foregroundStyle(
                                            LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .padding(.bottom, 5)
                                        .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
                                        .onAppear {
                                            startTimer()
                                        }
                                        .onDisappear {
                                            stopTimer()
                                        }
                                    Text("No Recipes Yet")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Tap the plus button on the bottom left to create an awesome recipe!")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                }
                            } else {
                                List {
                                    ForEach(groupedRecipes.keys.sorted(), id: \.self) { section in
                                        Section(header: Text(section)) {
                                            ForEach(groupedRecipes[section] ?? []) { recipe in
                                                HStack {
                                                    if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 100, height: 100)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                            .padding(.trailing, 8)
                                                    } else {
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.3))
                                                            .frame(width: 100, height: 100)
                                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                                            .overlay(
                                                                Image(systemName: "photo.badge.exclamationmark")
                                                                    .foregroundStyle(
                                                                        LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                                                    )
                                                                    .font(.system(size: 40))
                                                                    .fontWeight(.semibold)
                                                            )
                                                    }
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text(recipe.name)
                                                            .font(.headline)
                                                        Spacer()
                                                        
                                                        HStack(spacing: 0) {
                                                            ForEach(recipe.ingredients, id: \.name) { ingredient in
                                                                Text("\(ingredient.difficulty)")
                                                            }
                                                            Text(" • ")
                                                            ForEach(recipe.ingredients, id: \.name) { ingredient in
                                                                Text("\(ingredient.timeAmount) \(ingredient.unitTime)")
                                                            }
                                                        }
                                                        .font(.subheadline)
                                                        .foregroundColor(Color.gray)
                                                        .multilineTextAlignment(.leading)
                                                        
                                                        Text(recipe.saveDate.formatted(date: .abbreviated, time: .shortened))
                                                            .font(.subheadline)
                                                            .foregroundColor(Color.gray)
                                                    }
                                                    .padding(.top, 15)
                                                    .padding(.bottom, 8)
                                                    .fontDesign(.rounded)
                                                    
                                                    Spacer()
                                                    
                                                    VStack {
                                                        Button(action: {
                                                            selectedRecipeCooking = recipe
                                                        }) {
                                                            Image(systemName: "fork.knife")
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                        .sheet(item: $selectedRecipeCooking) { recipeToCook in
                                                            NavigationStack {
                                                                CookingMain(recipe: recipeToCook)
                                                            }
                                                        }
                                                        
                                                        Spacer()

                                                        Button(action: {
                                                            selectedRecipeEdit = recipe
                                                        }) {
                                                            Image(systemName: "pencil")
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                        .sheet(item: $selectedRecipeEdit) { recipeToEdit in
                                                            NavigationStack {
                                                                EditRecipe(recipe: recipeToEdit)
                                                            }
                                                        }
                                                        Spacer()

                                                        Button(action: {
                                                            recipe.isFavorite.toggle()
                                                        }) {
                                                            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                                                .transition(.scale.combined(with: .opacity))
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                    .padding(.vertical, 15)
                                                }
                                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                    Button("Delete") {
                                                        deleteRecipe(recipe)
                                                    }
                                                    .tint(Color.red)
                                                }
                                            }
                                        }
                                    }
                                }
//                                .alert("Start Cooking", isPresented: $isCooking) {
//                                    Button("Cancel", role: .cancel) { }
//                                } message: {
//                                    Text("CookingUI is coming soon...")
//                                }
                            }
                        }
                        .navigationTitle("Recipe+")
                        .navigationBarItems(
                            leading:
                                NavigationLink(destination: RecipeProfile()) {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.primary)
                                        .symbolEffect(.bounce, options: .repeat(1))
                                }, trailing:
                                Button(action: {
                                    showSettings = true
                                }) {
                                    Image(systemName: "gear")
                                        .foregroundColor(.primary)
                                        .symbolEffect(.bounce, options: .repeat(1))
                                })
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                NavigationLink(destination: AddNewRecipeIngred()) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(width: 60, height: 60)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(radius: 10)
                                        .symbolEffect(.bounce, options: .repeat(1))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
//                                .popoverTip(CreateRecipeTip())
//                                .onAppear { try? Tips.configure([]) }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                if isDoneEditing == true {
                                    HStack {
                                        Image(systemName: recipeConfirmedEditIcon ? "text.append" : "text.justify")
                                            .font(.system(size: 32))
                                            .padding(.trailing, 7)
                                            .contentTransition(.symbolEffect(.replace))
                                        Text("Recipe successfully saved!")
                                    }
                                    .padding(10)
                                    .frame(width: 250, height: 70)
                                    .background(isDarkMode ? Color.black : Color.white)
                                    .foregroundColor(isDarkMode ? Color.white : Color.black)
                                    .cornerRadius(12)
                                    .shadow(radius: 10)
                                    .scaleEffect(recipeConfimedEditVisibility)
                                    .opacity(recipeConfimedEditVisibility)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: recipeConfimedEditVisibility)
                                } else {
                                    HStack {
                                        Image(systemName: recipeConfirmedSaveIcon ? "checkmark.seal.text.page" : "rectangle.portrait")
                                            .font(.system(size: 32))
                                            .padding(.trailing, 7)
                                            .contentTransition(.symbolEffect(.replace))
                                        Text("Recipe successfully saved!")
                                    }
                                    .padding(10)
                                    .frame(width: 250, height: 70)
                                    .background(isDarkMode ? Color.black : Color.white)
                                    .foregroundColor(isDarkMode ? Color.white : Color.black)
                                    .cornerRadius(12)
                                    .shadow(radius: 10)
                                    .scaleEffect(recipeConfimedSaveVisibility)
                                    .opacity(recipeConfimedSaveVisibility)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: recipeConfimedSaveVisibility)
                                }
                                Spacer()
                            }
                            .padding(.bottom, 30)
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "menucard.fill")
                    Text("Recipes")
                }.tag(2)
                
                RecipeSearch()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }.tag(3)
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            RecipeSettings()
        }
    }
    
    private func deleteRecipe(_ recipe: RecipesViewModel) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            modelContext.delete(recipes[index])
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
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            withAnimation {
                rotatingSymbol = (rotatingSymbol + 1) % symbols.count
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct RecipeMain_Previews: PreviewProvider {
    static var previews: some View {
        RecipeMain()
    }
}
