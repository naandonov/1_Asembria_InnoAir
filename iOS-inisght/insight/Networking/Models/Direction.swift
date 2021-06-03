//
//  Direction.swift
//  insight
//
//  Created by Petar Petrov on 03/06/2021.
//

import Foundation

struct Direction: Decodable {
    let publicTransportOption: PublicTransportOption
    
    private enum CodingKeys: String, CodingKey {
        case publicTransportOption = "public_transport_option"
    }
}

extension Direction {
    struct PublicTransportOption: Decodable {
        let itineraries: [Itineraries]
    }
    
    struct Itineraries: Decodable {
        let fare: Fare
        let legs: [Leg]
    }
    
    struct Fare: Decodable {
        let currency: String
        let amount: String
    }
    
    struct Leg: Decodable {
        let departureTs: Date
        let arrivalTs: Date
        let distance: Double
        let travelMode: String // could be enum (walk, bus)
        let publicTransportInformation: PublicTransportInformation?
        let fromPlace: Stop
        let toPlace: Stop
        
        private enum CodingKeys: String, CodingKey {
            case departureTs = "departure_ts"
            case arrivalTs = "arrival_ts"
            case travelMode = "travel_mode"
            case publicTransportInformation = "public_transport_information"
            case distance = "distance_m"
            case fromPlace = "from_place"
            case toPlace = "to_place"
        }
    }
    
    struct PublicTransportInformation: Decodable {
        let lineName: String
        let intermediateStops: [Stop]
        
        private enum CodingKeys: String, CodingKey {
            case lineName = "line_name"
            case intermediateStops = "intermediate_stops"
        }
    }
    
    struct Place: Decodable {
        let name: String
    }
    
    struct Stop: Decodable {
        let name: String
        let placeType: String // could be enum (stop)
        let stopId: String?
        
        private enum CodingKeys: String, CodingKey {
            case name
            case placeType = "place_type"
            case stopInfo = "stop_info"
        }
        
        private enum StopInfoCodingKeys: String, CodingKey {
            case stopId = "stop_id"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            name = try container.decode(String.self, forKey: .name)
            placeType = try container.decode(String.self, forKey: .placeType)
            
            
            let stopInfo = try? container.nestedContainer(keyedBy: StopInfoCodingKeys.self, forKey: .stopInfo)
            stopId = try stopInfo?.decode(String.self, forKey: .stopId) ?? nil
        }
    }
    
    struct Location: Decodable {
        let lat: Double
        let lng: Double
    }
}

