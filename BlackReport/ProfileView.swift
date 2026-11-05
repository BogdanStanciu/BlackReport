import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: ReportsStore
    @AppStorage("profile_name") private var name = ""
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.deviceDefault.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("Language") {
                    Picker("Language", selection: $languageCode) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Statistics") {
                    LabeledContent("Reports sent", value: "\(store.reports.count)")
                }
            }
            .redHeaderSheet()
            .redTopBar()
        }
    }
}
