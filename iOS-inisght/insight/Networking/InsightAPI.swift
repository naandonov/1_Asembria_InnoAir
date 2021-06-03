//
//  InsightAPI.swift
//  insight
//
//  Created by Petar Petrov on 04/06/2021.
//

import Foundation

private enum InsightAPIString {
    static let baseURLString = "https://insight-spring.herokuapp.com"
    static let routePath = "/api/route"
    static let stopInfoPath = "\(routePath)/stopInfo/%@"
    static let userPath = "\(routePath)/user/%@"
}

enum InsightAPI {
    static func setRoute(_ route: InsightHandler.Route,
                         completion: @escaping (Result<Void, Error>) -> Void) {
        let handler = InsightHandler.postRoute(route)
        NetworkManager.shared.request(handler: handler, completion: completion)
    }
    
    static func setStopInfo(_ stopInfo: InsightHandler.StopInfo,
                            for stopId: String,
                            completion: @escaping (Result<InsightHandler.StopInfoResponse, Error>) -> Void) {
        let handler = InsightHandler.postStopInfo(stopId, stopInfo)
        NetworkManager.shared.request(handler: handler, completion: completion)
    }
    
    static func deleteUser(_ userId: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        let handler = InsightHandler.deleteUser(userId)
        NetworkManager.shared.request(handler: handler, completion: completion)
    }
}

enum InsightHandler {
    case postRoute(Route)
    case postStopInfo(String, StopInfo)
    case deleteUser(String)
}

extension InsightHandler: RequestHandlable {
    func makeRequest() throws -> URLRequest {
        switch self {
        case .postRoute(let route):
            let urlString = [InsightAPIString.baseURLString, InsightAPIString.routePath]
                .reduce("", {result, component in result + component})
            var request = try URLRequest.makeEncodedRequest(urlString: urlString)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(route)
            return request
        case .postStopInfo(let stopId, let stopInfo):
            let stopInfoPathString = String(format: InsightAPIString.stopInfoPath, stopId)
            let urlString = [InsightAPIString.baseURLString, stopInfoPathString]
                .reduce("", {result, component in result + component})
            var request = try URLRequest.makeEncodedRequest(urlString: urlString)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(stopInfo)
            return request
        case .deleteUser(let userId):
            let userPathString = String(format: InsightAPIString.userPath, userId)
            let urlString = [InsightAPIString.baseURLString, userPathString]
                .reduce("", {result, component in result + component})
            var request = try URLRequest.makeEncodedRequest(urlString: urlString)
            request.httpMethod = "DELETE"
            return request
        }
    }
    
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
}

extension InsightHandler {
    struct Route: Encodable {
        let userId: String
        let startStopId: String
        let endStopId: String
        let travelMode: String
        let lineName: String
    }
    
    struct StopInfo: Encodable {
        let travelMode: String
        let lineName: String
    }
    
    struct StopInfoResponse: Decodable {
        let passengersWillBoard: Bool
        let passengersWillDeboard: Bool
    }
}

