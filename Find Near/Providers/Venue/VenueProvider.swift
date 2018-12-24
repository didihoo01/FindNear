//
//  VenueProvider.swift
//  Find Near
//
//  Created by Jiahe Kuang on 12/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation

final class VenueProvider {
    
    static let shared: VenueProvider = VenueProvider()
    fileprivate let remoteVenueSourceAdapter: VenueSourceAdapter
    fileprivate let adapterQueue: DispatchQueue = DispatchQueue(label: "venue.adapter.queue")
    
    private init() {
        // Injecting alamofire client into the remote adapter to prevent framework dependencies
        let alamofireClient = AlamofireClient(backgroundURLSessionIdentifier: "venue.background.operation")
        remoteVenueSourceAdapter = RemoteVenueSourceAdapter(with: alamofireClient)
    }
    
    func getVenues(for venueCategory: VenueCategory, near address: String, within radius: Int = ConfigurationValues.fourSquareDefaultVenueRadius, completionOn queue: DispatchQueue, completion: @escaping (VenuesResult) -> Void) {
        adapterQueue.async { [weak self] in
            guard let strongSelf = self else {
                queue.async {
                    completion(.failure(.unknown))
                }
                return
            }
            strongSelf.remoteVenueSourceAdapter.getVenues(for: venueCategory, near: address, within: radius, completionOn: queue, completion: completion)
        }
    }
}
