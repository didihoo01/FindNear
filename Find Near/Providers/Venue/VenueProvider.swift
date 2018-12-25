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
    fileprivate let serialQueue = DispatchQueue(label: "serial.venue.queue")
    
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
        
        var foundVenues = [Venue]()
        var detailVenues = [Venue]()
        let group = DispatchGroup()
        group.enter()
        
        serialQueue.async { [weak self] in
            guard let strongSelf = self else {
                queue.async {
                    completion(.failure(.unknown))
                }
                return
            }
            strongSelf.getVenues(with: options, completionOn: queue, completion: { (result) in
                switch result{
                case .success(let venues):
                    foundVenues = venues
                case .failure(_):
                    queue.async {
                        completion(.failure(.notFound))
                        group.leave()
                        return
                    }
                }
                group.leave()
            })
        }
        
        serialQueue.async { [weak self] in
            _ = group.wait(timeout: .now() + .seconds(5))
            guard let strongSelf = self else {
                queue.async {
                    completion(.failure(.unknown))
                }
                return
            }
            var counter = 0
            for venue in foundVenues {
                strongSelf.getVenue(with: venue.id, completionOn: queue, completion: { (result) in
                    switch result {
                    case .success(let venue):
                        detailVenues.append(venue)
                    default:
                        break
                    }
                    counter+=1
                    if counter == foundVenues.count {
                        guard detailVenues.count > limit else {
                            queue.async {
                                completion(.success(detailVenues))
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
        }
    }
}
