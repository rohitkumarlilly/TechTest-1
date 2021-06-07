//
//  SearchTrainInteractorTest.swift
//  MyTravelHelperTests
//
//  Created by pcadmin on 07/06/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainInteractorTest: XCTestCase {

    var sut: SearchTrainInteractor!
    
    override func setUp() {
        sut = SearchTrainInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testFetchallStations_success() {
        // Arrange
        let mockPresenter = MockSearchTrainPresenter()
        sut.presenter = mockPresenter
        let expectation = XCTBlockExpectation {
            mockPresenter.stationListFetchedCallCount > 0
        }
        // Act
        sut.fetchallStations()
        wait(for: [expectation], timeout: 2)
        // Assert
        XCTAssertNotNil(mockPresenter.stationList)
    }
    
    func testFetchTrainsFromSource_success() {
        // Arrange
        let mockPresenter = MockSearchTrainPresenter()
        sut.presenter = mockPresenter
        let expectation = XCTBlockExpectation {
            mockPresenter.fetchedTrainsListCallCount > 0
        }
        // Act
        sut.fetchTrainsFromSource(sourceCode: "bfstc", destinationCode: "lburn")
        wait(for: [expectation], timeout: 2)
        // Assert
        XCTAssertEqual(mockPresenter.fetchedTrainsListCallCount, 1)
    }
}

