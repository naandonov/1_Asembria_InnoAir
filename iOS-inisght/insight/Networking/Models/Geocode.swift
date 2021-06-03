//
//  Geocode.swift
//  insight
//
//  Created by Petar Petrov on 03/06/2021.
//

import Foundation

struct GoogleResults<T: Decodable>: Decodable {
    let results: [T]
}

struct Geocode: Decodable {
    let location: Location
    let formattedAddress: String
    
    private enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case geometry
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        formattedAddress = try container.decode(String.self, forKey: .formattedAddress)
        
        let geometryContainer = try container.nestedContainer(keyedBy: GeometryCodingKeys.self,
                                                          forKey: .geometry)
        
        location = try geometryContainer.decode(Location.self, forKey: .location)
    }
}

extension Geocode {
    struct Location: Decodable {
        let lat: String
        let lng: String
        
        var locationString: String {
            "\(lat),\(lng)"
        }
    }
}

