//
//  LoadingScreen.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/17/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.6
    @State private var offsetY: CGFloat = 0
    @State private var mainViewOpacity: Double = 0.0
    
    @AppStorage("isLightMode") private var isLightMode: Bool = true
    
    var body: some View {
        VStack {
            if isActive {
                RecipeMain()
                    .opacity(mainViewOpacity)
                
            } else {
                VStack {
                    Image(isLightMode ? "AppIconDark" : "AppIconLight")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .frame(width: 200, height: 200)
                        .foregroundColor(.black)
                        .scaleEffect(scale)
                        .offset(y: offsetY)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.75)) {
                                scale = 1.3
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            offsetY = -UIScreen.main.bounds.height
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isActive = true
                            withAnimation(.easeInOut(duration: 1.0)) {
                                mainViewOpacity = 1.0
                            }
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
