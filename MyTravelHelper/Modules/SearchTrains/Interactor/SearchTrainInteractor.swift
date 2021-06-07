//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing
import Alamofire

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    let session = URLSession.shared
    
    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
            let urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML"
            guard let url = URL(string: urlString) else { return }
            session.dataTask(with: url) { data, response, err in
                guard let _data = data else { return }
                let station = try? XMLDecoder().decode(Stations.self, from: _data)
                self.presenter!.stationListFetched(list: station!.stationsList)
            }.resume()
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        let urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=\(sourceCode)"
        guard let url = URL(string: urlString) else { return }
        if Reach().isNetworkReachable() {
            session.dataTask(with: url) { data, response, err in
                guard let _data = data else { return }
                let stationData = try? XMLDecoder().decode(StationData.self, from: _data)
                if let _trainsList = stationData?.trainsList {
                    self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                } else {
                    self.presenter!.showNoTrainAvailbilityFromSource()
                }
            }.resume()
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            let _urlString = "http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=\(trainsList[index].trainCode)&TrainDate=\(dateString)"
            guard let url = URL(string: _urlString) else { return }
            if Reach().isNetworkReachable() {
                session.dataTask(with: url) { data, response, err in
                    guard let _data = data else { return }
                    let trainMovements = try? XMLDecoder().decode(TrainMovementsData.self, from: _data)
                    
                    if let _movements = trainMovements?.trainMovements {
                        let sourceIndex = _movements.firstIndex(where: {$0.locationCode?.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                        let destinationIndex = _movements.firstIndex(where: {$0.locationCode?.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                        let desiredStationMoment = _movements.filter{$0.locationCode?.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                        let isDestinationAvailable = desiredStationMoment.count == 1
                        
                        if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                            _trainsList[index].destinationDetails = desiredStationMoment.first
                        }
                    }
                    group.leave()
                }.resume()
            } else {
                self.presenter!.showNoInterNetAvailabilityMessage()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
