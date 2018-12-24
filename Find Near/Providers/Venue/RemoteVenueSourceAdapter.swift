//
//  RemoteVenueSourceAdapter.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
final class RemoteVenueSourceAdapter: VenueSourceAdapter {
    
    fileprivate let webServiceClient: WebServiceClient
    fileprivate let venueAPIBaseURL = ConfigurationValues.fourSquareVenueEndPoint
    
    init(with client: WebServiceClient) {
        self.webServiceClient = client
    }
    
    // This remote adapter API has dependencies on the foursquare venue API, consider changing its implementation when switching to a different API vendor
    func getVenues(for venueCategory: VenueCategory, near address: String, within radius: Int, completionOn queue: DispatchQueue, completion: @escaping (VenuesResult) -> Void) {
        
        guard let url = URL(string: venueAPIBaseURL.appending("/search")) else {
            queue.async { completion(.failure(.unknown)) }
            return
        }
        // Set defaultRadius to 1 mile, whichs about 1610 meters
        let params: Params = ["near": address,
                              "intent": "checkin",
                              "client_id": ConfigurationValues.fourSquareClientID,
                              "client_secret": ConfigurationValues.fourSquareClientSecret,
                              "v": ConfigurationValues.fourSquareAPIVersion,
                              "categoryId": venueCategory.description,
                              "radius": "\(radius)"]
        
        let headers = ["Content-Type": "application/json"]
        
        webServiceClient.get(url: url, with: params, headers: headers, queue: queue) { (result, error) in
            guard
                let searchResult = result,
                let response = searchResult["response"] as? WebServiceResult,
                let venues = response["venues"] as? [WebServiceResult],
                venues.count > 0 else {
                    completion(.failure(.notFound))
                    return
                }
            var foundVenues = [Venue]()
            for venue in venues {
                if let foundVenue = Venue.createVenue(from: venue) {
                    foundVenues.append(foundVenue)
                }
            }
            completion(.success(foundVenues))
        }
    }
    
    func getVenue(id venueId: VenueId, completionOn queue: DispatchQueue, completion: @escaping (VenueResult) -> Void) {
        guard let url = URL(string: venueAPIBaseURL.appending("/").appending(venueId)) else {
            queue.async { completion(.failure(.unknown)) }
            return
        }
        
        let params: Params = ["client_id": ConfigurationValues.fourSquareClientID,
                              "client_secret": ConfigurationValues.fourSquareClientSecret,
                              "v": ConfigurationValues.fourSquareAPIVersion]

        let headers = ["Content-Type": "application/json"]

        webServiceClient.get(url: url, with: params, headers: headers, queue: queue) { (result, error) in
            guard
                let searchResult = result,
                let response = searchResult["response"] as? WebServiceResult,
                let venue = response["venue"] as? WebServiceResult,
                let detailedVenue = Venue.createDetailVenue(from: venue) else {
                    completion(.failure(.notFound))
                    return
                }
            completion(.success(detailedVenue))
        }
    }

}
