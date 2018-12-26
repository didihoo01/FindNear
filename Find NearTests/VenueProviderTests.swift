//
//  VenueProviderTests.swift
//  Find NearTests
//
//  Created by Jiahe Kuang on 12/25/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import XCTest
@testable import Find_Near

class VenueProviderTests: XCTestCase {
    let envoyLocation = "410 Townsend St, San Francisco, CA"

    let viewModel = VenueListViewModel()
    let sharedVenueProvider = VenueProvider.shared
    
    override func setUp() {
        super.setUp()
        viewModel.updateSearchVenueAddress(to: envoyLocation)
        viewModel.updateVenueCategory(to: .coffeeShop)
    }

    func testGetVenues() {
        let expectation = XCTestExpectation()
        sharedVenueProvider.getVenues(with: viewModel.options, completionOn: DispatchQueue.main) { (result) in
            switch result {
            case .success(let venues):
                if venues.count > 0 {
                    expectation.fulfill()
                }
                else {
                    XCTFail("expected one more one location to be return from address: 410 Townsend St, San Francisco, CA")
                }
            case .failure(_):
                XCTFail("expected one more one location to be return from address: 410 Townsend St, San Francisco, CA")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testSearchByVenueId() {
        let venuId = "4a844f01f964a5203bfc1fe3"
        let expectedVenue = Venue(id: "4a844f01f964a5203bfc1fe3",
                                  name: "Philz Coffee",
                                  address: "201 Berry St",
                                  rating: 9.0,
                                  photoUrl: "https://fastly.4sqi.net/img/general/612x612/313179_W3r42kWLmA3yGEtTjlQFtEtoi3syWWv2FxLM-_TmBII.jpg")
        let expectation = XCTestExpectation()
        sharedVenueProvider.getVenue(with: venuId, completionOn: DispatchQueue.main) { (result) in
            switch result {
            case .success(let venue):
                if venue == expectedVenue {
                    expectation.fulfill()
                }
                else {
                    XCTFail("expected venue: \(expectedVenue) AND returned venue: \(venue)")
                }
            case .failure(let error):
                XCTFail("expected venue\(expectedVenue) AND returned error: \(error.localizedDescription)")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSearchTop15VenueByRating() {
        let expectation = XCTestExpectation()
        sharedVenueProvider.getTopVenues(with: viewModel.options, completionOn: DispatchQueue.main) { (result) in
            switch result {
                case .success(let venues):
                    if venues.count == 15 {
                        expectation.fulfill()
                    }
                    else {
                        XCTFail("expected one more one location to be return from address: 410 Townsend St, San Francisco, CA")
                    }
                case .failure(_):
                XCTFail("expected one more one location to be return from address: 410 Townsend St, San Francisco, CA")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    // Ratings are bound to change, therefore this test only testing return count
    func testFindHighestRatingCoffeeshop() {
        let expectation = XCTestExpectation()
        sharedVenueProvider.getTopVenues(limit: 1, with: viewModel.options, completionOn: DispatchQueue.main) { (result) in
            switch result {
            case .success(let venues):
                if venues.count == 1 {
                    expectation.fulfill()
                }
                else {
                    XCTFail("expected one more one location to be return from address: 410 Townsend St, San Francisco, CA")
                }
            case .failure(_):
                XCTFail("expected one more one location to be return from address: 410 Townsend St, San Francisco, CA")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
