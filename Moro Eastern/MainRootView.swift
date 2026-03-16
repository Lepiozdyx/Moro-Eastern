//
//  ContentView.swift
//  Moro Eastern
//
//  Created by Алкександр Степанов on 12.03.2026.
//

import SwiftUI

struct MainRootView: View {
    @State private var appState    = AppState()
    @State private var marketStore = MarketStore()
    @State private var dishStore   = DishStore()

    var body: some View {
        ContentView()
            .environment(appState)
            .environment(marketStore)
            .environment(dishStore)
    }
}

#Preview {
    MainRootView()
}
