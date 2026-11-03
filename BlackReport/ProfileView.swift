//
//  ProfileView.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 02/11/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: ReportsStore
    @AppStorage("profile_name") private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Dati") {
                    TextField("Il tuo nome", text: $name)
                }
                Section("Statistiche") {
                    LabeledContent("Note inviate", value: "\(store.reports.count)")
                }
            }
            .navigationTitle("Profilo")
        }
    }
}
