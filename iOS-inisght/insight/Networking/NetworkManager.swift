//
//  NetworkManager.swift
//  insight
//
//  Created by Petar Petrov on 03/06/2021.
//

import Foundation

private enum SofiaTrafficAPIStrings {
    static let baseURLString = "https://api-routes.sofiatraffic.bg"
    static let arrivalsBaseURLString = "https://api-arrivals.sofiatraffic.bg/"
    static let directionPath = "/api/v1/trip-guru/"
    static let timetablePath = "/api/v1/arrivals/%@/"
    static let queryParameter = "?arrive_by=0&from_place=%@&itineraries_requested_count=1&lang=bg&optimization=fastest&planning_ts=%@&skipped_travel_options=bicycle,taxi,walk&to_place=%@"
}

protocol RequestHandlable {
    func makeRequest() throws -> URLRequest
    var decoder: JSONDecoder { get }
}

enum RequestHandlerError: Error {
    case unableToEncodeString
    case invalidURL
}

extension DateFormatter {
    static func apiDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm'Z'"
        
        return formatter
    }
}

enum SofiaTrafficAPI {
    static func getDirection(from startLocation: Geocode.Location,
                             to endLocation: Geocode.Location,
                             completion: @escaping (Result<Direction, Error>) -> Void) {
        let handler = SofiaTrafficHandler.direction(startLocation, endLocation)
        NetworkManager.shared.request(handler: handler,
                                      completion: completion)
    }
    
    static func getTimetable(for stopId: String,
                             completion: @escaping (Result<StopTimetable, Error>) -> Void) {
        let request = SofiaTrafficHandler.timetable(stopId)
        NetworkManager.shared.request(handler: request,
                                      completion: completion)
    }
}

enum SofiaTrafficHandler {
    case direction(Geocode.Location, Geocode.Location)
    case timetable(String)
}

extension SofiaTrafficHandler: RequestHandlable {
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        
        switch self {
        case .direction:
            decoder.dateDecodingStrategy = .iso8601
        case .timetable:
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm:ss"
            decoder.dateDecodingStrategy = .formatted(formatter)
        }
        
        return decoder
    }
    
    func makeRequest() throws -> URLRequest {
        switch self {
        case .direction(let fromLocation, let toLocation):
            let dateFormatter = DateFormatter.apiDateFormatter()
            let parameters = String(format: SofiaTrafficAPIStrings.queryParameter,
                                    fromLocation.locationString,
                                    dateFormatter.string(from: Date()),
                                    toLocation.locationString)
            
            let urlString = [SofiaTrafficAPIStrings.baseURLString,
                             SofiaTrafficAPIStrings.directionPath,
                             parameters]
                .reduce("", { result, component in result + component })
            
            return try URLRequest.makeEncodedRequest(urlString: urlString)
        case .timetable(let stopId):
            let path = String(format: SofiaTrafficAPIStrings.timetablePath, stopId)
            let urlString = [SofiaTrafficAPIStrings.arrivalsBaseURLString, path]
                .reduce("", { result, component in result + component })
            
            return try URLRequest.makeEncodedRequest(urlString: urlString)
        }
    }
}

extension URLRequest {
    static func makeEncodedRequest(urlString: String) throws -> Self {
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw NSError()
        }
        
        return URLRequest(url: url)
    }
}

final class NetworkManager {
    private let session = URLSession.shared
    
    static let shared = NetworkManager()
    
    /// completion is always called on main thread
    func request<T>(handler: RequestHandlable, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        do {
            let urlRequest = try handler.makeRequest()
            
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    mainify(completion(.failure(error)))
                }
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode,
                   (200...299).contains(statusCode),
                   let data = data {
                    do {
                        let object = try handler.decoder.decode(T.self, from: data)
                        mainify(completion(.success(object)))
                    } catch {
                        mainify(completion(.failure(error)))
                    }
                }
            }
            
            task.resume()
        } catch {
            mainify(completion(.failure(error)))
        }
    }
    
    /// completion is always called on main thread
    func request(handler: RequestHandlable, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let urlRequest = try handler.makeRequest()
            
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    mainify(completion(.failure(error)))
                }
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode,
                   (200...299).contains(statusCode) {
                    mainify(completion(.success(())))
                }
            }
            
            task.resume()
        } catch {
            mainify(completion(.failure(error)))
        }
    }
}

func mainify(_ closure: @autoclosure @escaping () -> Void) -> Void  {
    DispatchQueue.main.async {
        closure()
    }
}

