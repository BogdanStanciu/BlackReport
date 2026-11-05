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
        selectedPlace != nil && !isSending   // la nota è facoltativa
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
            .redHeaderSheet()
            .redTopBar()
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isReportFocused = false }
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
            Text("Choose on the map")
        } footer: {
            Text("Move the map: the crosshair finds the nearest businesses. Or tap a marker.")
        }
    }

    private var locationSection: some View {
        Section("Selected business") {
            if locationManager.isDenied && places.isEmpty {
                Text("Location permission denied. You can still use the map, or enable it in Settings › Privacy › Location Services.")
                    .foregroundStyle(.secondary)
            } else if isSearching {
                HStack { ProgressView(); Text("Searching nearby businesses…") }
            } else if let place = selectedPlace {
                VStack(alignment: .leading, spacing: 2) {
                    Label(place.name, systemImage: "mappin.circle.fill")
                    Text(String(format: "%.5f, %.5f", place.latitude, place.longitude))
                        .font(.caption).foregroundStyle(.secondary)
                }
            } else {
                Text("No business found here. Move the map.")
                    .foregroundStyle(.secondary)
            }

            Button {
                locationManager.request()
                if let loc = locationManager.location { focusOn(loc.coordinate) }
            } label: {
                Label("Back to my location", systemImage: "location.fill")
            }
        }
    }

    private var placesSection: some View {
        Section("Nearby businesses (max 5)") {
            ForEach(places) { place in
                Button {
                    selectedID = place.id
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(place.name).foregroundStyle(.primary)
                            Text(verbatim: "\(Int(place.distance)) m · \(place.address)")
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
        Section("Note (optional)") {
            TextEditor(text: $reportText)
                .frame(minHeight: 100)
                .focused($isReportFocused)

            Button {
                Task { await sendReport() }
            } label: {
                HStack {
                    Spacer()
                    if isSending { ProgressView() } else { Text("Send report").bold() }
                    Spacer()
                }
            }
            .disabled(!canSend)
        }
    }

    private var recentSection: some View {
        Section("Recent reports") {
            ForEach(store.reports.prefix(5)) { report in
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.placeName).font(.headline)
                    if !report.text.isEmpty {
                        Text(report.text).font(.subheadline)
                    }
                    Text(report.date, format: .dateTime.day().month(.abbreviated).year().hour().minute())
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
                limit: 5
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
