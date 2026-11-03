//
//  PlacePickerMap.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 02/11/26.
//

import SwiftUI
import MapKit

/// Mini mappa con mirino fisso al centro: sposti la mappa e il mirino
/// "punta" l'attività. Tocca un segnaposto per sceglierlo direttamente.
struct PlacePickerMap: View {
    let places: [Place]
    @Binding var selectedID: UUID?
    @Binding var position: MapCameraPosition
    var onCenterChange: (CLLocationCoordinate2D) -> Void

    var body: some View {
        Map(position: $position, selection: $selectedID) {
            UserAnnotation()
            ForEach(places) { place in
                Marker(place.name, systemImage: "storefront.fill", coordinate: place.coordinate)
                    .tint(place.id == selectedID ? .red : .blue)
                    .tag(place.id)
            }
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            onCenterChange(context.camera.centerCoordinate)
        }
        .overlay {
            // Mirino fisso al centro della mappa
            Image(systemName: "scope")
                .font(.title)
                .foregroundStyle(.red)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
