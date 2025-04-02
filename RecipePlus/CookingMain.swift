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
    
    @State private var currentStepIndex = 0
    @State private var isPlaying = false
    @State private var timerProgress: Double = 0
    var steps: [String]

    var body: some View {
        VStack {
            if steps.isEmpty {
                Text("Error: No steps found!")
                    .font(.title2)
                    .foregroundColor(.gray)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(steps.indices, id: \.self) { index in
                            ZStack {
                                Text(steps[index])
                                    .font(.title3)
                                    .padding()
                                    .foregroundColor(index == currentStepIndex ? .blue : .primary)
                                    .cornerRadius(8)
                                    .id(index)
                                    .frame(width: 300)
                                    .multilineTextAlignment(.center)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 300, height: 250)
                                    .foregroundColor(index == currentStepIndex ? Color.blue.opacity(0.1) : Color.clear)
                            }
                            .containerRelativeFrame(.horizontal, count: verticalSizeClass == .regular ? 1 : 2, spacing: 1)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.15)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.3)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(16, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
            }
        }
    }
}

struct CookingMain_Previews: PreviewProvider {
    static var previews: some View {
        CookingMain(steps: ["The first step is to add all of your ingredients to a large mixing bowl", "After, add the oil and mix well", "Next, add the salt and pepper to taste"])
    }
}
