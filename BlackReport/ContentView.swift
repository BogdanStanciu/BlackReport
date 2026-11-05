//
//  ContentView.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 02/11/26.
//


import SwiftUI

struct ContentView: View {
    @AppStorage(AppTheme.storageKey) private var themeCode = AppTheme.red.rawValue

    private var currentTheme: AppTheme { AppTheme.from(themeCode) }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(currentTheme.color)
    }
}
