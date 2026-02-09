//
//  ContentView.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 2/9/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if DEBUG
        .debugOverlay()
        #endif
    }
}

#Preview {
    ContentView()
}
