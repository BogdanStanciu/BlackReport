//
//  HomeView.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 02/11/26.
//
import SwiftUI
import MapKit

@MainActor
struct HomeView: View {
    @EnvironmentObject private var store: ReportsStore
    @StateObject private var locationManager = LocationManager()

    @State private var places: [Place] = []
    @State private var selectedID: UUID?
    @State private var reportText = ""
    @State private var isSearching = false
    @State private var isSending = false

    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var gpsCenter: CLLocationCoordinate2D?
    @State private var didSkipInitialCameraEvent = false
    @State private var searchTask: Task<Void, Never>?
    @FocusState private var isReportFocused: Bool

    private let gpsRadius: CLLocationDistance = 150   // ricerca dal GPS
    private let pinRadius: CLLocationDistance = 100   // ricerca dal mirino

    private var selectedPlace: Place? { places.first { $0.id == selectedID } }

    private var canSend: Bool {
        selectedPlace != nil
        && !reportText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !isSending
    }

    var body: some View {
        NavigationStack {
            Form {
                mapSection
                locationSection
                if !places.isEmpty { placesSection }
                reportSection
                if !store.reports.isEmpty { recentSection }
            }
            .navigationTitle("Black Report")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fine") { isReportFocused = false }
                }
            }
            .onAppear { locationManager.request() }
            .onChange(of: locationManager.location) { _, newLocation in
                guard let newLocation else { return }
                focusOn(newLocation.coordinate)
            }
        }
    }

    // MARK: - Sezioni

    private var mapSection: some View {
        Section {
            PlacePickerMap(
                places: places,
                selectedID: $selectedID,
                position: $cameraPosition,
                onCenterChange: handleCameraChange
            )
            .frame(height: 240)
            .listRowInsets(EdgeInsets())
        } header: {
            Text("Scegli sulla mappa")
        } footer: {
            Text("Sposta la mappa: il mirino cerca le attività più vicine. Oppure tocca un segnaposto.")
        }
    }

    private var locationSection: some View {
        Section("Attività selezionata") {
            if locationManager.isDenied && places.isEmpty {
                Text("Permesso posizione negato. Puoi comunque usare la mappa, oppure abilitalo da Impostazioni › Privacy › Localizzazione.")
                    .foregroundStyle(.secondary)
            } else if isSearching {
                HStack { ProgressView(); Text("Cerco le attività vicine…") }
            } else if let place = selectedPlace {
                VStack(alignment: .leading, spacing: 2) {
                    Label(place.name, systemImage: "mappin.circle.fill")
                    Text(String(format: "%.5f, %.5f", place.latitude, place.longitude))
                        .font(.caption).foregroundStyle(.secondary)
                }
            } else {
                Text("Nessuna attività trovata qui. Sposta la mappa.")
                    .foregroundStyle(.secondary)
            }

            Button {
                locationManager.request()
                if let loc = locationManager.location { focusOn(loc.coordinate) }
            } label: {
                Label("Torna alla mia posizione", systemImage: "location.fill")
            }
        }
    }

    private var placesSection: some View {
        Section("Attività vicine (max 10)") {
            ForEach(places) { place in
                Button {
                    selectedID = place.id
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(place.name).foregroundStyle(.primary)
                            Text("\(Int(place.distance)) m · \(place.address)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if place.id == selectedID {
                            Image(systemName: "checkmark").foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
    }

    private var reportSection: some View {
        Section("Nota") {
            TextEditor(text: $reportText)
                .frame(minHeight: 100)
                .focused($isReportFocused)

            Button {
                Task { await sendReport() }
            } label: {
                HStack {
                    Spacer()
                    if isSending { ProgressView() } else { Text("Invia nota").bold() }
                    Spacer()
                }
            }
            .disabled(!canSend)
        }
    }

    private var recentSection: some View {
        Section("Ultimi report") {
            ForEach(store.reports.prefix(5)) { report in
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.placeName).font(.headline)
                    Text(report.text).font(.subheadline)
                    Text(report.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Ricerca

    /// Centra la mappa su una coordinata (GPS) e cerca da lì.
    private func focusOn(_ coordinate: CLLocationCoordinate2D) {
        gpsCenter = coordinate
        cameraPosition = .region(
            MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        )
        runSearch(at: coordinate, radius: gpsRadius)
    }

    /// Chiamata quando l'utente smette di spostare la mappa.
    private func handleCameraChange(_ center: CLLocationCoordinate2D) {
        // Ignora l'evento iniziale al caricamento della mappa
        if !didSkipInitialCameraEvent {
            didSkipInitialCameraEvent = true
            return
        }
        // Ignora gli spostamenti causati dal GPS (già cercati in focusOn)
        if let gps = gpsCenter {
            let distance = CLLocation(latitude: gps.latitude, longitude: gps.longitude)
                .distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))
            if distance < 5 { return }
        }
        runSearch(at: center, radius: pinRadius)
    }

    private func runSearch(at coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        searchTask?.cancel()
        isSearching = true
        searchTask = Task {
            let found = await PlaceFinder.nearby(
                to: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude),
                radius: radius,
                limit: 10
            )
            guard !Task.isCancelled else { return }
            places = found
            selectedID = found.first?.id      // pre-seleziona la più vicina
            isSearching = false
        }
    }

    // MARK: - Invio

    private func sendReport() async {
        guard let place = selectedPlace else { return }
        isReportFocused = false
        isSending = true
        let report = Report(
            text: reportText.trimmingCharacters(in: .whitespacesAndNewlines),
            placeName: place.name,
            address: place.address,
            latitude: place.latitude,
            longitude: place.longitude,
            date: .now
        )
        await store.send(report)
        reportText = ""
        isSending = false
    }
}
