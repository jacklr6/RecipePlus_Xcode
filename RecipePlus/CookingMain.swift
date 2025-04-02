//
//  CookingMain.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/4/25.
//

import SwiftUI
import SwiftData

struct CookingMain: View {
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
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(steps.indices, id: \.self) { index in
                                Text(steps[index])
                                    .font(.title3)
                                    .foregroundColor(index == currentStepIndex ? .blue : .primary)
                                    .padding()
                                    .background(index == currentStepIndex ? Color.blue.opacity(0.1) : Color.clear)
                                    .cornerRadius(8)
                                    .id(index)
                            }
                        }
                    }
                    .onChange(of: currentStepIndex) { _, targetIndex in
                        withAnimation { proxy.scrollTo(targetIndex, anchor: .center) }
                    }
                }
            }

            HStack {
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                }
                .padding()

                ProgressView(value: timerProgress)
                    .frame(width: 200)
            }
        }
        .padding()
    }

    func togglePlayback() {
        isPlaying.toggle()
    }
}
