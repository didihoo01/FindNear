//
//  VenueListViewController.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation

typealias VenueOptions = [String: String]

final class VenueListViewModel {
    
    // Main data source to drive the venue list
    fileprivate var venues = [Venue]()
    
    // Cache map of location+category for the current version
    fileprivate var cachedVenuesMap = [String: [Venue]]()
    
    // Default venue option, it should react to the changes made by the user (via UI)
    // It can also support addtional options
    // Set defaultRadius to 1 mile, whichs about 1610 meters
    
    // Note: This option profile is 100% API dependant,
    // In this case, it is relying on the Foursquare API structures
    // This pattern allows minimal code changes to a different API vendor and new UI requirements
    var options = ["categoryId": VenueCategory.coffeeShop.description,
                   "intent": "checkin",
                   "client_id": ConfigurationValues.fourSquareClientID,
                   "client_secret": ConfigurationValues.fourSquareClientSecret,
                   "v": "\(ConfigurationValues.fourSquareAPIVersion)",
                   "radius": "\(ConfigurationValues.fourSquareDefaultVenueRadius)"]

    // Set default venue category to coffee shop
    fileprivate var venueCategory: VenueCategory = .coffeeShop
    fileprivate var searchVenueAddress: String = ""

    func venuesCount() -> Int {
        return venues.count
    }
    
    func venue(at index: Int) -> Venue {
        guard index < venues.count else { fatalError("venue index out of bound") }
        return venues[index]
    }
    
    func updateVenueCategory(to category: VenueCategory) {
        options["categoryId"] = category.description
    }
    
    func updateSearchVenueAddress(to address: String) {
        options["near"] = address
    }
    
    func searchAddress() -> String? {
        return options["near"]
    }

    func searchVenues(completionOn queue: DispatchQueue = DispatchQueue.main, completion: @escaping (VenueError?) -> Void) {
        guard
            let near = options["near"],
            let categoryId = options["categoryId"] else {
                queue.async { completion(VenueError.notFound) }
                return
            }
        if let cachedVenue = cachedVenuesMap[near+categoryId] {
            venues = cachedVenue
            queue.async { completion(nil) }
        }
        else {
//            // Debug code for UI testings when premium API call quota exceeded limit
//            VenueProvider.shared.getVenues(with: options, completionOn: queue) { [weak self] (result) in
//                switch result {
//                case .success(let venues):
//                    self?.venues = venues
//                    self?.cachedVenuesMap[near+categoryId] = venues
//                    completion(nil)
//                case .failure(let error):
//                    self?.venues = []
//                    completion(error)
//                }
//            }
            
            VenueProvider.shared.getTopVenues(with: options, completionOn: queue) { [weak self] (result) in
                switch result {
                case .success(let venues):
                    self?.venues = venues
                    self?.cachedVenuesMap[near+categoryId] = venues
                    completion(nil)
                case .failure(let error):
                    self?.venues = []
                    completion(error)
                }
            }
        }
    }
}
