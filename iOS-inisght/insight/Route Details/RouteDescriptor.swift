//
//  RouteDescriptor.swift
//  insight
//
//  Created by Nikolay Andonov on 4.06.21.
//

import Foundation

struct UpcomingStop: StorageMainainable {
    static var key: String = "UpcomingStop"
    var stopId: String
}

struct ActiveRoute: StorageMainainable {
    static var key: String = "ActiveRoute"
    
    var destination: String
    var stopIds: [String]
    var travelMode: String
    var lineName: String
}

struct RouteDescriptor {
  
    let startContent: String
    let endContent: String
    let travelMode: String
    let lineName: String
    let duration: String
    
    var stops: [Direction.Stop]
    
    init(direction: Direction) {
        guard let legs = direction.publicTransportOption.itineraries.first?.legs else {
            startContent = ""
            endContent = ""
            stops = []
            travelMode = ""
            lineName = ""
            duration = ""
            return
        }
        
        var stops: [Direction.Stop] = []
        stops.append(legs[0].toPlace)
        if let innerStops = legs[1].publicTransportInformation?.intermediateStops {
            stops += innerStops
        }
        
        
    
        stops.append(legs[legs.count - 1].fromPlace)
        self.stops = stops
        
        startContent = "\(Int(legs[0].distance)) метра пеша"
        endContent = "\(Int(legs[legs.count - 1].distance)) метра пеша"
        
        travelMode = legs[1].travelMode
        lineName = legs[1].publicTransportInformation?.lineName ?? ""
        
        let minutes = Calendar.current
            .dateComponents([.minute], from: legs[0].departureTs, to: legs[2].arrivalTs)
            .minute
        duration = "\(Int(minutes ?? 0)) минути"
    }
    
    var fullTransitName: String {
        var result = ""
        switch travelMode {
        case "trolley":
            result += "Тролейбус"
        case "bus":
            result += "Автобус"
        case "tram":
            result += "Трамвай"
        case "subway":
            result += "Метро"
        default:
            break
        }
        
        result += " \(lineName)"
        return result
    }
    
    func firstIndexOfStop(_ id: String) -> Int {
        return stops.firstIndex(where: {$0.stopId == id}) ?? -1
    }
}
