//
//  StopTimetable.swift
//  insight
//
//  Created by Petar Petrov on 03/06/2021.
//

import Foundation

struct StopTimetable: Decodable {
    let lines: [Line]
}

extension StopTimetable {
    struct Line: Decodable {
        let vehicleType: String // could be enum
        let arrivals: [Arrival]
        
        private enum CodingKeys: String, CodingKey {
            case vehicleType = "vehicle_type"
            case arrivals
        }
    }
    
    struct Arrival: Decodable {
        let time: Date
    }
}
