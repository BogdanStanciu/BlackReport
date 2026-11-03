//
//  ReportStore.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 02/11/26.
//

import Foundation

struct Report: Identifiable, Codable {
    var id = UUID()
    let text: String
    let placeName: String
    let address: String
    let latitude: Double
    let longitude: Double
    let date: Date
}

@MainActor
final class ReportsStore: ObservableObject {
    @Published private(set) var reports: [Report] = []
    private let key = "saved_reports"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Report].self, from: data) {
            reports = decoded
        }
    }

    /// Salva il report in locale e (opzionale) la invia a un backend.
    func send(_ report: Report) async {
        reports.insert(report, at: 0)
        persist()
        await upload(report)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(reports) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// TODO: sostituisci con la tua API. Per ora non fa nulla.
    private func upload(_ report: Report) async {
        // var request = URLRequest(url: URL(string: "https://tuo-server.it/api/notes")!)
        // request.httpMethod = "POST"
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.httpBody = try? JSONEncoder().encode(note)
        // _ = try? await URLSession.shared.data(for: request)
    }
}
