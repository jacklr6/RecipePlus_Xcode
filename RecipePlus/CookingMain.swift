//
//  CookingMain.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/4/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct CookingMain: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    let recipe: RecipesViewModel
    var steps: [StepsViewModel] {
        recipe.steps
    }

    @State private var currentStepIndex = 0
    @State private var isPlaying = false
    @State private var timerProgress: Double = 0
    @State private var showHintArrow = false
    @State private var lastInteractionDate = Date()
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @AppStorage("TimeIntervalSave") var timeIntervalSave: TimeInterval = 10

    var body: some View {
        VStack {
            if steps.isEmpty {
                Text("Error: No steps found!")
                    .font(.title2)
                    .foregroundColor(.gray)
            } else {
                ZStack {
                    VStack {
                        if let image = selectedImage ?? (recipe.imageData != nil ? UIImage(data: recipe.imageData!) : nil) {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 320)
                                    .overlay(
                                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white]), startPoint: .top, endPoint: .bottom)
                                    )
                                Text(recipe.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .offset(y: 130)
                            }
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 320)
                                    .overlay(
                                        LinearGradient(gradient: Gradient(colors: [Color.gray, Color.white]), startPoint: .top, endPoint: .bottom)
                                    )
                                Text(recipe.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .offset(y: 130)
                            }
                        }
                    }
                    .offset(y: -300)
                    .ignoresSafeArea(.all)
                        
                    ZStack {
                        TabView(selection: $currentStepIndex) {
                            ForEach(steps.indices, id: \.self) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(index == currentStepIndex ? Color.blue.opacity(0.1) : Color.clear)
                                        .frame(width: 300, height: 250)
                                        .animation(.easeInOut, value: currentStepIndex)
                                    
                                    Text(steps[index].text)
                                        .font(.title3)
                                        .frame(width: 260, height: 230)
                                        .foregroundColor(index == currentStepIndex ? .blue : .primary)
                                        .cornerRadius(8)
                                        .multilineTextAlignment(.center)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 250)
                        .animation(.easeInOut, value: currentStepIndex)
                        .onChange(of: currentStepIndex, initial: false) { _,_   in
                            userDidInteract()
                        }
                        
                        if showHintArrow {
                            if verticalSizeClass == .regular {
                                Image(systemName: "arrow.right")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .offset(x: 172)
                                    .symbolEffect(.wiggle, options: .speed(0.75))
                                    .transition(.opacity)
                            } else {
                                Image(systemName: "arrow.right")
                                    .font(Font.system(size: 40))
                                    .fontWeight(.semibold)
                                    .offset(x: 192)
                                    .symbolEffect(.wiggle, options: .speed(0.75))
                                    .transition(.opacity)
                            }
                        }
                        
                        Color.clear
                            .allowsHitTesting(false)
                            .onAppear {
                                lastInteractionDate = Date()
                                startIdleTimer()
                            }
                    }
                }
            }
        }
    }

    private func userDidInteract() {
        lastInteractionDate = Date()
        if showHintArrow {
            withAnimation {
                showHintArrow = false
            }
        }
    }

    private func startIdleTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(lastInteractionDate)
            if elapsed > timeIntervalSave && !showHintArrow {
                withAnimation {
                    showHintArrow = true
                }
            }
        }
    }
}

struct CookingMain_Previews: PreviewProvider {
    static var previews: some View {
        let mockSteps = [
            StepsViewModel(text: "The first step is to add the flour and eggs to a large mixing bowl. Mix until combined"),
            StepsViewModel(text: "Put the mixture onto a baking sheet and put it into the oven, 375 for 20 minutes.")
        ]
        let mockRecipe = RecipesViewModel(name: "Test Recipe", sectionName: "Appetizer", steps: mockSteps)
        CookingMain(recipe: mockRecipe)
    }
}
