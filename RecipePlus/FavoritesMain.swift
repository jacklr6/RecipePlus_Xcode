//
//  FavoritesMain.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI
import SwiftData

struct RecipeFavorites: View {
    @State private var selectedTab = 2
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
    
    var favoriteItems: [RecipesViewModel] {
        recipes.filter { $0.isFavorite }
    }
    
    var groupedRecipes: [String: [RecipesViewModel]] {
        Dictionary(grouping: recipes, by: { $0.sectionName })
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    VStack {
                        if favoriteItems.isEmpty {
                            VStack {
                                Image(systemName: "heart.slash")
                                    .font(.largeTitle)
                                    .foregroundStyle(
                                        LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .padding(.bottom, 5)
                                Text("No Favorites Yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Tap the heart next to recipe to add your favorite recipes!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            .offset(x: 0, y: 22)
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
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        .padding(.trailing, 8)
                                                } else {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 80, height: 80)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        .padding(.trailing, 8)
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
                                                        .padding(.leading, -2)
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
//                                                    Button(action: {
//                                                        selectedRecipeCooking = recipe
//                                                        isCooking = true
//                                                    }) {
//                                                        Image(systemName: "fork.knife")
//                                                    }
//                                                    .buttonStyle(PlainButtonStyle())
//                                                    .navigationDestination(isPresented: $isCooking) {
//                                                        if let recipeToCook = selectedRecipeCooking {
//                                                            CookingMain(recipe: recipeToCook)
//                                                        }
//                                                    }
//                                                    Spacer()
                                                    
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
                            .alert("Start Cooking", isPresented: $isCooking) {
                                Button("Cancel", role: .cancel) { }
                            } message: {
                                Text("CookingUI is coming soon...")
                            }
                        }
                    }
                    .navigationTitle("Favorites")
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

struct RecipeFavorites_Previews: PreviewProvider {
    static var previews: some View {
        RecipeMain()
    }
}
