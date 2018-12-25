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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
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
