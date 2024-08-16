//
//  FireStoreGeoSwift.swift
//  FirestoreGeoSwift
//
//  Created by Fabio Dantas on 16/08/2024.
//

import FirebaseFirestore
import CoreLocation

public class FireStoreGeoSwift {
    
    public static let `default` = FireStoreGeoSwift()
    
    private init() {}
}

public extension FireStoreGeoSwift {
    
    // MARK: Example using the query
    func getDocuments(query: Query) async throws -> [Data] {
        // Radius in Kilometers
        // Get all documents in the user collection withing 250km of San Francisco
        let query = getNearbyDocumentsQuery(radius: 250, center: CLLocationCoordinate2D(latitude:  37.773972, longitude: -122.431297), collection: "users")
        let snapshot = try await query.getDocuments()
        let items = snapshot.documents.map {$0.data()}
        var list = [Data]()
        for item in items {
            if let obj = try? JSONSerialization.data(withJSONObject:item) {
                list.append(obj)
            }
        }
        return list
    }
    
    func getNearbyDocumentsQuery(radius: Double, center: CLLocationCoordinate2D, collection: String) -> Query {
        let center = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
        let range: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.0 * radius / 110.574, longitude: 1.0 * radius / (111.320 * cos((center.latitude * Double.pi) / (180))))
        // MARK: This code assumes your collection model has a longitude and latitude field as a double
        let query = Firestore.firestore().collection(collection)
            .whereField("longitude", isGreaterThanOrEqualTo: center.longitude - range.longitude)
            .whereField("longitude", isLessThanOrEqualTo: center.longitude + range.longitude)
            .whereField("latitude", isGreaterThanOrEqualTo: center.latitude - range.latitude)
            .whereField("latitude", isLessThanOrEqualTo: center.latitude + range.latitude)
        return query
    }
}
