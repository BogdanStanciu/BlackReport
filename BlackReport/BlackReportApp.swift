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
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store)
        }
    }
}
