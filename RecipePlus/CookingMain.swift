//
//  CookingMain.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/4/25.
//

import SwiftUI
import SwiftData

struct CookingMain: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Query private var recipes: [RecipesViewModel]

    @State private var currentStepIndex = 0
    @State private var isPlaying = false
    @State private var timerProgress: Double = 0
    @State private var showHintArrow = false
    @State private var lastInteractionDate = Date()
    @AppStorage("TimeIntervalSave") private var timeIntervalSave = 10

    var steps: [String]
    let idleThreshold: TimeInterval = 10

    var body: some View {
        VStack {
            if steps.isEmpty {
                Text("Error: No steps found!")
                    .font(.title2)
                    .foregroundColor(.gray)
            } else {
                ZStack {
                    TabView(selection: $currentStepIndex) {
                        ForEach(steps.indices, id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(index == currentStepIndex ? Color.blue.opacity(0.1) : Color.clear)
                                    .frame(width: 300, height: 250)
                                    .animation(.easeInOut, value: currentStepIndex)

                                Text(steps[index])
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
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .offset(x: 172)
                            .symbolEffect(.wiggle, options: .speed(0.75))
                            .transition(.opacity)
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
            if elapsed > idleThreshold && !showHintArrow {
                withAnimation {
                    showHintArrow = true
                }
            }
        }
    }
}

struct CookingMain_Previews: PreviewProvider {
    static var previews: some View {
        CookingMain(steps: ["The first step is to add all of your ingredients to a large mixing bowl.", "After, add the oil and mix well.", "Next, add the flour and mix until a dough forms.", "Next, add the salt and pepper to taste."])
    }
}
