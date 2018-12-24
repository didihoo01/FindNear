//
//  VenueListViewController.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation

final class VenueListViewModel {
    fileprivate var venues = [Venue]()
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
        venueCategory = category
    }
    
    func updateSearchVenueAddress(to address: String) {
        searchVenueAddress = address
    }

    func searchVenues(completionOn queue: DispatchQueue = DispatchQueue.main, completion: @escaping (Error?) -> Void) {
        VenueProvider.shared.getVenues(for: venueCategory, near: searchVenueAddress, completionOn: queue) {[weak self] (result) in
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
