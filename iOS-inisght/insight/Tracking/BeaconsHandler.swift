//
//  BeaconsHandler.swift
//  insight
//
//  Created by Nikolay Andonov on 4.06.21.
//

import Foundation

protocol BeaconsHandlerDelegate: AnyObject {
    func didChangeStop()
}

class BeaconsHandler {
    static let shared = BeaconsHandler()
    weak var delegate: BeaconsHandlerDelegate?
    private let notificationCenter = NotificationCenter.default
    private init() {}
    
    func startListening() {
        TrackingManager.shared.startListentingForBeaconsInProximity()
        startTracking()
    }
    
    deinit {
        stopTracking()
    }
    
    private func startTracking() {
        notificationCenter.addObserver(self,
                                       selector: #selector(self.didLocateBeacons),
                                       name: TrackingManager.Constants.Notifications.BeaconsFound,
                                       object: nil)
    }
    
    private func stopTracking() {
        notificationCenter.removeObserver(self, name: TrackingManager.Constants.Notifications.BeaconsFound, object: nil)
    }
    
    @objc func didLocateBeacons(_ notification: Notification) {
        guard let beacon = notification.userInfo?[TrackingManager.Constants.Notifications.UserInfoBeaconsKey] as? [Beacon] else {
            return
        }
        generateMessageForBeacons(beacon)
    }
    
    func generateMessageForBeacons(_ beacons: [Beacon]) {
        guard let activeRoute: ActiveRoute = StorageManager.shared.getItem() else {
            return
        }
        var resultString = ""
        for (index, stopId) in activeRoute.stopIds.enumerated() {
            if beacons.map({String($0.major)}).contains(stopId) {
                let name = activeRoute.stopNames[index]
                if index == 0 {
                    resultString += "Достигнахте началната зададена спирка. "
//                    SofiaTrafficAPI.getTimetable(for: stopId) { [weak self] result in
//                        if case let .success(timeTable) = result {
//                            if let table = timeTable.arrivals.first {
//                                let minutes = Calendar.current
//                                    .dateComponents([.minute], from: Date(), to: table.time)
//                                    .minute
//
//                                resultString +=  activeRoute.fullTransportName + " пристига след" + "\(minutes ?? 0)" + " минути"
//                                self?.handle(message: resultString, for: stopId)
//                            } else {
//                                self?.handle(message: resultString, for: stopId)
//                            }
//                        }
//                    }
                    handle(message: resultString, for: stopId)

                } else if index == activeRoute.stopIds.count - 1 {
                    resultString = "Спирка " + name + ". " + "Моля напуснете превозното средство за да продължите към вашата дестинация"
                    handle(message: resultString, for: stopId)
                } else {
                    let remainingSteps = activeRoute.stopIds.count - 1 - index
                    resultString = "Спирка " + name + ". " + " Остава " + remainingSteps.alphaNumericValue +  " \(remainingSteps == 1 ? "спирка" : "спирки")" + " до вашата дестинация"
                    handle(message: resultString, for: stopId)
                }
                
                return
            }
        }
    }
    
    func handle(message: String, for stopId: String) {
        SpeechService.shared.speak(text: message, completion: {_ in })
        StorageManager.shared.setItem(UpcomingStop(stopId: stopId))
        delegate?.didChangeStop()
    }
}

private extension Int {
    var alphaNumericValue: String {
        switch self {
        case 1:
            return "една"
        case 2:
            return "две"
        case 3:
            return "три"
        case 4:
            return "четри"
        case 5:
            return "пет"
        case 6:
            return "шест"
        case 7:
            return "седем"
        case 8:
            return "осем"
        default:
            return "\(self)"
        }
    }
}
