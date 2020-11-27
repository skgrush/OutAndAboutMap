//
//  ContentView.swift
//  OutAndAboutMap
//
//  Created by Samuel Grush on 11/26/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainMapView()
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
        }
    }
}
#endif
