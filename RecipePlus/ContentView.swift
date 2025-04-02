//
//  ContentView.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("isLightMode") private var isLightMode: Bool = true
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedColorScheme: ColorScheme?
    
    var body: some View {
        SplashScreenView()
            .preferredColorScheme(isLightMode ? selectedColorScheme : (isDarkMode ? .dark : .light))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
