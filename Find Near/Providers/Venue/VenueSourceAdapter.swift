//
//  VenueSourceAdapter.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

// Source Adapter Protocol for both remote and local

import Foundation

enum VenueError: Error {
    case notFound
    case unknown
}

typealias VenuesResult = Result<[Venue], VenueError>
typealias VenueResult = Result<Venue, VenueError>
typealias VenueId = String

protocol VenueSourceAdapter {
    func getVenues(for venueCategory: VenueCategory, near address: String, within radius: Int, completionOn queue: DispatchQueue, completion: @escaping (VenuesResult) -> Void)
    
    func getVenue(id venueId: VenueId, completionOn queue: DispatchQueue, completion: @escaping (VenueResult) -> Void)
}
