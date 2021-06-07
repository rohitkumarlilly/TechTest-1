//
//  MockSearchTrainPresenter.swift
//  MyTravelHelperTests
//
//  Created by pcadmin on 07/06/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class MockSearchTrainPresenter: InteractorToPresenterProtocol {
    
    var stationListFetchedCallCount = 0
    var fetchedTrainsListCallCount = 0
    var showNoTrainAvailbilityFromSourceCallCount = 0
    var showNoInterNetAvailabilityMessageCallCount = 0
    var stationList: [Station]?
    
    func stationListFetched(list: [Station]) {
        stationList = list
        stationListFetchedCallCount += 1
    }
    
    func fetchedTrainsList(trainsList: [StationTrain]?) {
        fetchedTrainsListCallCount += 1
    }
    
    func showNoTrainAvailbilityFromSource() {
        showNoTrainAvailbilityFromSourceCallCount += 1
    }
    
    func showNoInterNetAvailabilityMessage() {
        showNoInterNetAvailabilityMessageCallCount += 1
    }
    
}
