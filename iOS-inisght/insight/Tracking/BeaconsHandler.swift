//
//  BeaconsHandler.swift
//  insight
//
//  Created by Nikolay Andonov on 4.06.21.
//

import UIKit
import UserNotifications


protocol BeaconsHandlerDelegate: AnyObject {
    func didChangeStop()
    func didReachFinalStop()
}

struct UserEntity: StorageMainainable {
    static var key: String = "UserEntity"
    let id: String
}

class BeaconsHandler: NSObject {
    private static let InteractionCategory = "interaction.category"
    private static let InteractionActionUUID = "BF02C842-8DA8-416B-8E8D-C07D98E93FDE"
    
    static let shared = BeaconsHandler()
    weak var delegate: BeaconsHandlerDelegate?
    private let notificationCenter = NotificationCenter.default
    private override init() { super.init() }
    
    private lazy var userNotificationCenter: UNUserNotificationCenter = {
        let center = UNUserNotificationCenter.current()
        return center
    }()
    
    func startListening() {
        TrackingManager.shared.startListentingForBeaconsInProximity()
        startTracking()
        userNotificationCenter.requestAuthorization(options: [.badge, .alert, .sound]) { [weak self] _,_  in
            self?.userNotificationCenter.delegate = self
        }
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
                    if let userEntity: UserEntity = StorageManager.shared.getItem() {
                        InsightAPI.setRoute(InsightHandler.Route(userId: userEntity.id,
                                                                 startStopId: activeRoute.stopIds.first ?? "0",
                                                                 endStopId: activeRoute.stopIds.last ?? "0",
                                                                 travelMode: activeRoute.travelMode,
                                                                 lineName: activeRoute.lineName),
                                            completion: {_ in })
                    }
                    resultString += "Достигнахте началната зададена спирка. "
                    SofiaTrafficAPI.getTimetable(for: stopId) { [weak self] result in
                        if case let .success(timeTable) = result,
                           let vehicle = timeTable.lines.first(where: {$0.name == activeRoute.lineName}),
                           let table = vehicle.arrivals.first {
                                let minutes = Calendar.current
                                    .dateComponents([.minute], from: Date(), to: table.time)
                                    .minute

                                resultString +=  activeRoute.fullTransportName + " пристига след" + "\(minutes ?? 0)" + " минути"
                                self?.handle(message: resultString, for: stopId)
                            } else {
                                self?.handle(message: resultString, for: stopId)
                            }
                    }

                } else if index == activeRoute.stopIds.count - 1 {
                    resultString = "Спирка " + name + ". " + "Моля напуснете превозното средство за да продължите към вашата дестинация"
                    handle(message: resultString, for: stopId)
                    
                    if let userEntity: UserEntity = StorageManager.shared.getItem() {
                        InsightAPI.deleteUser(userEntity.id, completion: {_ in })
                    }
                    delegate?.didReachFinalStop()
                    
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
        if UIApplication.shared.applicationState != .active {
            let content = UNMutableNotificationContent()
            content.title = "Известие"
            content.body = message
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "sound.aiff"))
            content.categoryIdentifier = BeaconsHandler.InteractionCategory

            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: BeaconsHandler.InteractionActionUUID, content: content, trigger: trigger)
            
            DispatchQueue.main.async {

                UIApplication.shared.beginBackgroundTask {
                    print("time out")
                }
            }
            
            SpeechService.shared.speak(text: message) { [weak self] data in
                SpeechService.shared.store(audioData: data, name: "sound")
                    self?.userNotificationCenter.add(request, withCompletionHandler: { _ in
                        DispatchQueue.main.async {
                            UIApplication.shared.endReceivingRemoteControlEvents()
                        }
                    })
            }
        } else {
            SpeechService.shared.speak(text: message, completion: { data in
                guard let data = data else {
                    return
                }
                SpeechService.shared.play(data)
            })
            StorageManager.shared.setItem(UpcomingStop(stopId: stopId))
        }
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

//MARK: - UNUserNotificationCenterDelegate

extension BeaconsHandler: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
}
