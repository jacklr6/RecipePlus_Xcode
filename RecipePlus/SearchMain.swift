//
//  SearchMain.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData

struct RecipeSearch: View {
    @State private var selectedTab = 2
    @State private var searchTerm = ""
    @AppStorage("showSettings") private var showSettings: Bool = false
    @AppStorage("primaryColor") private var primaryColor: Int = 4
    @AppStorage("secondaryColor") private var secondaryColor: Int = 5
    
    @State private var selectedRecipeEdit: RecipesViewModel?
    @State private var isEditing: Bool = false
    @State private var selectedRecipeCooking: RecipesViewModel?
    @State private var isCooking: Bool = false
    @State private var isStove: Bool = true
    
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [RecipesViewModel]
    
    var filteredRecipes: [RecipesViewModel] {
        return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var groupedRecipes: [String: [RecipesViewModel]] {
        Dictionary(grouping: recipes, by: { $0.sectionName })
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    VStack {
                        if searchTerm.isEmpty {
                            VStack {
                                Image(systemName: "sparkle.magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundStyle(
                                        LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .padding(.bottom, 5)
                                Text("No Search Results")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Tap the search bar to search for your favorite recipes!")
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
                                                        .padding(.trailing, 2)
                                                        Text("•")
                                                            .padding(.trailing, 2)
                                                        ForEach(recipe.ingredients, id: \.name) { ingredient in
                                                            Text("\(ingredient.timeAmount) \(ingredient.unitTime)")
                                                        }
                                                    }
                                                    .font(.subheadline)
                                                    .foregroundColor(Color.gray)
                                                    
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
                                                        isCooking = true
                                                    }) {
                                                        Image(systemName: "fork.knife")
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .navigationDestination(isPresented: $isCooking) {
                                                        if let recipeToCook = selectedRecipeCooking {
                                                            CookingMain(recipe: recipeToCook)
                                                        }
                                                    }
                                                    Spacer()

                                                    Button(action: {
                                                        selectedRecipeEdit = recipe
                                                        isEditing = true
                                                    }) {
                                                        Image(systemName: "pencil")
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .navigationDestination(isPresented: $isEditing) {
                                                        if let recipeToEdit = selectedRecipeEdit {
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
//                            .alert("Start Cooking", isPresented: $isCooking) {
//                                Button("Cancel", role: .cancel) { }
//                            } message: {
//                                Text("CookingUI is coming soon...")
//                            }
                        }
                    }
                    .navigationTitle("Search")
                    .searchable(text: $searchTerm, prompt: "Search Recipes")
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
                }
            }
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
}

struct RecipeSearch_Previews: PreviewProvider {
    static var previews: some View {
        RecipeMain()
    }
}
