//
//  PlaceFinder.swift
//  BlackReport
//
//  Created by bogdan.stanciu on 02/11/26.
//

import MapKit

struct Place: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String
    let distance: Double          // metri dal punto di ricerca
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum PlaceFinder {
    /// Cerca attività / punti di interesse entro `radius` metri dal punto dato.
    /// Restituisce al massimo `limit` risultati, dal più vicino al più lontano.
    static func nearby(to location: CLLocation,
                       radius: CLLocationDistance = 150,
                       limit: Int = 10) async -> [Place] {
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: radius)
        let search = MKLocalSearch(request: request)

        guard let response = try? await search.start() else { return [] }

        let places = response.mapItems
            .compactMap { item -> Place? in
                guard let name = item.name,
                      let itemLocation = item.placemark.location else { return nil }
                return Place(
                    name: name,
                    address: item.placemark.title ?? "",
                    distance: itemLocation.distance(from: location),
                    latitude: itemLocation.coordinate.latitude,
                    longitude: itemLocation.coordinate.longitude
                )
            }
            .sorted { $0.distance < $1.distance }

        return Array(places.prefix(limit))
    }
}
