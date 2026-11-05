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

    private let endpoint = URL(
        string: "http://192.168.1.182:3000/"
    )!

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Report].self, from: data) {
            reports = decoded
        }
    }

    func send(_ report: Report) async {
        reports.insert(report, at: 0)
        persist()

        await upload(report)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(reports) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }

    private func upload(_ report: Report) async {
        do {
            var request = URLRequest(url: endpoint)

            request.httpMethod = "POST"
            request.timeoutInterval = 30

            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            request.setValue(
                "application/json",
                forHTTPHeaderField: "Accept"
            )
            
            request.setValue(DeviceIdentifier.current, forHTTPHeaderField: "X-Device-Id")
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            request.httpBody = try encoder.encode(report)

            if let body = request.httpBody,
               let json = String(data: body, encoding: .utf8) {
                print("Request JSON: \(json)")
            }

            let (data, response) = try await URLSession.shared.data(
                for: request
            )

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }

            print("HTTP Status: \(httpResponse.statusCode)")
            print("Response: \(String(data: data, encoding: .utf8) ?? "")")

            guard (200...299).contains(httpResponse.statusCode) else {
                print("Upload failed with status \(httpResponse.statusCode)")
                return
            }

            print("Upload successful")

        } catch {
            print("Upload error: \(error.localizedDescription)")
        }
    }
}
