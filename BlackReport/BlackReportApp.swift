//
//  BlackReportApp.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 02/11/26.
//

import SwiftUI

@main
struct BlackReportApp: App {
    @StateObject private var store = ReportsStore()
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.deviceDefault.rawValue
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store).environment(\.locale, Locale(identifier: languageCode))
        }
    }
}
