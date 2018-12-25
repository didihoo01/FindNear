//
//  VenueListViewModelTests.swift
//  Find NearTests
//
//  Created by Jiahe Kuang on 12/24/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import XCTest
@testable import Find_Near

class VenueListViewModelTests: XCTestCase {

    let viewModel = VenueListViewModel()
        
    func testUpdateVenueNearLocation() {
        let expectedNearLocation = "410 Townsend St, San Francisco, CA"
        viewModel.updateSearchVenueAddress(to: "410 Townsend St, San Francisco, CA")
        guard let near = viewModel.options ["near"] else {
            XCTFail("expected a near location, but return nil from view model options")
            return
        }
        XCTAssertEqual(expectedNearLocation, near)
    }
    
    func testUpdateVenueCategory() {
        let expectedVenueCategory = ConfigurationValues.barsCategoryIDs.description
        viewModel.updateVenueCategory(to: .bar)
        guard let venueCategoryIDs = viewModel.options ["categoryId"] else {
            XCTFail("expected a categoryId, but return nil from view model options")
            return
        }
        XCTAssertEqual(expectedVenueCategory, venueCategoryIDs)
    }
    
    func testSearchInvalidLocation() {
        let invalidLocation = "Definitely not a location"
        let expectation = XCTestExpectation()
        viewModel.updateSearchVenueAddress(to: invalidLocation)
        viewModel.searchVenues { (error) in
            if let searchError = error as? VenueError, searchError == VenueError.notFound {
                expectation.fulfill()
            }
            else{
                XCTFail("search location: \(invalidLocation) expecting VenueError.notFound")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
