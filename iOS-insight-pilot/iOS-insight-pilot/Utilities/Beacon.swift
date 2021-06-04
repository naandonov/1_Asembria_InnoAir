//
//  Beacon.swift
//  insight
//
//  Created by Nikolay Andonov on 3.06.21.
//

import Foundation

struct Beacon: Codable, Equatable {
    let minor: Int
    let major: Int
    let rssi: Int
    
    public static func == (lhs: Beacon, rhs: Beacon) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor
    }
}
