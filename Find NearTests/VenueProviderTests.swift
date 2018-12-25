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

    func testGetVenues() {
        viewModel.updateSearchVenueAddress(to: envoyLocation)
        viewModel.updateVenueCategory(to: .coffeeShop)
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

}
