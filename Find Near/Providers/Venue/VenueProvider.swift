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
    
    func getVenues(with options: VenueOptions, completionOn queue: DispatchQueue, completion: @escaping (VenuesResult) -> Void) {
        adapterQueue.async { [weak self] in
            guard let strongSelf = self else {
                queue.async {
                    completion(.failure(.unknown))
                }
                return
            }
            strongSelf.remoteVenueSourceAdapter.getVenues(with: options, completionOn: queue, completion: completion)
        }
    }
    
    func getVenue(with id: VenueId, completionOn queue: DispatchQueue, completion: @escaping (VenueResult) -> Void) {
        adapterQueue.async { [weak self] in
            guard let strongSelf = self else {
                queue.async {
                    completion(.failure(.unknown))
                }
                return
            }
            strongSelf.remoteVenueSourceAdapter.getVenue(id: id, completionOn: queue, completion: completion)
        }
    }
    
    func getTopVenues(limit: Int = 15, with options: VenueOptions, completionOn queue: DispatchQueue, completion: @escaping (VenuesResult) -> Void) {
        
        getVenues(with: options, completionOn: queue, completion: {[weak self] (result) in
            switch result{
            case .success(let venues):
                var counter = 0
                var detailVenues = [Venue]()
                for venue in venues {
                    self?.getVenue(with: venue.id, completionOn: queue, completion: { (result) in
                        switch result {
                        case .success(let venue):
                            detailVenues.append(venue)
                        default:
                            break
                        }
                        counter+=1
                        if counter == venues.count {
                            guard detailVenues.count > limit else {
                                if detailVenues.count > 0 {
                                    queue.async { completion(.success(detailVenues)) }
                                }
                                else {
                                    queue.async { completion(.failure(.notFound)) }
                                }
                                return
                            }
                            // sort the venues by their ratings in a descending order
                            detailVenues.sort { $0.rating > $1.rating }
                            queue.async {
                                completion(.success(Array(detailVenues[..<limit])))
                            }
                        }
                    })
                }
            case .failure(_):
                queue.async {
                    completion(.failure(.notFound))
                    return
                }
            }
        })
    }
}
