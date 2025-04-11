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
    
    @State private var showGauge: Bool = false
    @State private var currentStepIndex = 0
    @State private var isPlaying = false
    @State private var timerProgress: Double = 0
    @State private var showHintArrow = false
    @State private var lastInteractionDate = Date()
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var noImageFound: Bool = false
    @AppStorage("primaryColor") private var primaryColor: Int = 4
    @AppStorage("secondaryColor") private var secondaryColor: Int = 5
    @AppStorage("TimeIntervalSave") var timeIntervalSave: TimeInterval = 10
    @AppStorage("isLightMode") private var isLightMode: Bool = true
    @AppStorage("stepCounterPreference") private var stepCounterPreference = 0

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
                            ZStack(alignment: .bottom) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 320)
                                    .clipped()
                                
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 320)
                            }
                            .overlay(
                                Text(recipe.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 20),
                                alignment: .bottom
                            )
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [colorFromTag(primaryColor), colorFromTag(secondaryColor)]), startPoint: .topTrailing, endPoint: .bottomLeading))
                                    .frame(height: 320)
                                    .overlay(
                                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white]), startPoint: .top, endPoint: .bottom)
                                    )
                                
                                Image(systemName: "photo.badge.exclamationmark")
                                    .symbolEffect(.bounce, options: .nonRepeating)
                                    .font(.system(size: 70))
                                    .offset(y: 10)
                                    .onTapGesture {
                                        noImageFound = true
                                    }
                                
                                Text(recipe.name)
                                    .font(.system(size: 35))
                                    .fontWeight(.bold)
                                    .offset(y: 125)
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
                                    
                                    Text(highlightTimers(in: steps[index].text))
                                        .font(.title3)
                                        .frame(width: 260, height: 230)
                                        .foregroundColor(index == currentStepIndex ? .blue : .primary)
                                        .cornerRadius(8)
                                        .multilineTextAlignment(.center)
                                    
                                    if stepCounterPreference == 1 {
                                        Image(systemName: "\(index + 1).circle")
                                            .font(.title)
                                            .symbolEffect(.bounce, options: .nonRepeating)
                                            .foregroundColor(Color.blue)
                                            .offset(x: -125, y: -100)
                                    } else {
                                        Gauge(value: Double(currentStepIndex), in: 0...Double(max(steps.count - 1, 1))) {
                                        } currentValueLabel: {
                                            Text("\(currentStepIndex + 1)")
                                                .foregroundColor(.blue)
                                        }
                                        .gaugeStyle(.accessoryCircularCapacity)
                                        .tint(.blue)
                                        .opacity(showGauge ? 1 : 0)
                                        .scaleEffect(x: 0.6, y: 0.6)
                                        .offset(x: -120, y: -95)
                                        .onAppear {
                                            withAnimation(.easeIn(duration: 0.9)) {
                                                showGauge = true
                                            }
                                        }
                                    }
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
                .alert("No Image Found", isPresented: $noImageFound) {
                    Button("Cool!", role: .cancel) { noImageFound = false }
                } message: {
                    Text("To add an image, edit the recipe from the main page.")
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
    
    func highlightTimers(in text: String) -> AttributedString {
        var attributed = AttributedString(text)
        let pattern = #"\{\d{2}:\d{2}\}"#

        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsrange = NSRange(text.startIndex..., in: text)
            for match in regex.matches(in: text, range: nsrange) {
                if let range = Range(match.range, in: text) {
                    let swiftRange = attributed.range(of: String(text[range]))
                    if let swiftRange = swiftRange {
                        attributed[swiftRange].foregroundColor = .orange
                        attributed[swiftRange].font = .title3
                    }
                }
            }
        }
        return attributed
    }
}

struct CookingMain_Previews: PreviewProvider {
    static var previews: some View {
        let mockSteps = [
            StepsViewModel(text: "The first step is to add the flour and eggs to a large mixing bowl. Mix until combined"),
            StepsViewModel(text: "Put the mixture onto a baking sheet and put it into the oven, 375 for {00:12}."),
            StepsViewModel(text: "Put the mixture onto a baking sheet and put it into the oven, 375 for {01:45}."),
            StepsViewModel(text: "Put the mixture onto a baking sheet and put it into the oven, 375 for {26:20}.")
        ]
        let mockRecipe = RecipesViewModel(name: "Test Recipe", sectionName: "Appetizer", steps: mockSteps)
        CookingMain(recipe: mockRecipe)
    }
}
