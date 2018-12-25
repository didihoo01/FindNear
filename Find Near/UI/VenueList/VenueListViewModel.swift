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
    fileprivate var venues = [Venue]()
    
    // Default venue option, it should react to the changes made by the user
    // It will also support addtional options
    // Set defaultRadius to 1 mile, whichs about 1610 meters
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

    func searchVenues(completionOn queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Error?) -> Void) {
        VenueProvider.shared.getTopVenues(with: options, completionOn: queue) { [weak self] (result) in
            switch result {
            case .success(let venues):
                self?.venues = venues
                completion(nil)
            case .failure(let error):
                self?.venues = []
                completion(error)
            }
        }
    }
}
