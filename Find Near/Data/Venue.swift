//
//  Venue.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

enum VenueCategory: CustomStringConvertible {
    case coffeeShop
    case restaurant
    case bar
    
    var description: String {
        switch self {
        case .coffeeShop:
            return "4bf58dd8d48988d1e0931735"
        case .restaurant:
            return "4d4b7105d754a06374d81259"
        case .bar:
            return "4bf58dd8d48988d116941735"
        }
    }
}

struct Venue {
    let id: String
    let name: String
    let address: String
    let rating: Double
    let photoUrl: String
    
    static func createVenue(from result: WebServiceResult) -> Venue? {
        guard
            let id = result["id"] as? String,
            let name = result["name"] as? String,
            let location = result["location"] as? WebServiceResult,
            let address = location["address"] as? String else { return nil}
        return Venue(id: id, name: name, address: address, rating: 0, photoUrl: "")
    }
    
    static func createDetailVenue(from result: WebServiceResult) -> Venue? {
        guard
            let id = result["id"] as? String,
            let name = result["name"] as? String,
            let location = result["location"] as? WebServiceResult,
            let address = location["address"] as? String,
            let rating = result["rating"] as? Double,
            let bestPhoto = result["bestPhoto"] as? WebServiceResult,
            let photoPrefix = bestPhoto["prefix"] as? String,
            let photoSuffix = bestPhoto["suffix"] as? String,
            let photoWidth = bestPhoto["width"] as? Int,
            let photoHeight = bestPhoto["height"] as? Int else { return nil }
        let photoUrl = "\(photoPrefix)\(photoWidth)x\(photoHeight)\(photoSuffix)"
        return Venue(id: id, name: name, address: address, rating: rating, photoUrl: photoUrl)
    }

}
