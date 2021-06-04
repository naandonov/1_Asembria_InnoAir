//
//  StopTimetable.swift
//  insight
//
//  Created by Petar Petrov on 03/06/2021.
//

import Foundation

struct StopTimetable: Decodable {
    let lines: String
    let arrivals: [Arrivals]
}

extension StopTimetable {
    struct Line {
        let vehicleType: String // could be enum
        
        private enum CodingKeys: String, CodingKey {
            case vihicleType = "vehicle_type"
            case arrivals
        }
    }
    
    struct Arrivals: Decodable {
        let time: Date
    }
}
