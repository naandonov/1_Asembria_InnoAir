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

struct Line: Decodable {
    let arrivals: [Arrivals]
    let name: String
    let vehicleType: String // could be enum
    
    private enum CodingKeys: String, CodingKey {
        case vehicleType = "vehicle_type"
        case name
        case arrivals
    }
}

struct Arrivals: Decodable {
    let time: Date
}
