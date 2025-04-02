//
//  RecipeProfile.swift
//  RecipePlus
//
//  Created by Jack Rogers on 3/1/25.
//

import SwiftUI

struct RecipeProfile: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: RecipeMain()) {
                Text("Profile")
            }
        }
    }
}

struct RecipeProfile_Previews: PreviewProvider {
    static var previews: some View {
        RecipeProfile()
    }
}
