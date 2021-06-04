//
//  TrackingManager.swift
//  insight
//
//  Created by Nikolay Andonov on 3.06.21.
//

import CoreLocation


enum TrackingError: Error {
    case locationDisabled
    case locationEnabledInUseOnly
    case locationNotDetermined
}

private struct BeaconRecord {
    init(beacon: Beacon) {
        self.beacon = beacon
        recordDate = Date()
    }
    let beacon: Beacon
    let recordDate: Date
}

extension TrackingManager {
    enum Constants {
        enum Beacons {
            static let RegionUUID = "F7826DA6-4FA2-4E98-8024-BC5B71E0893E"
            static let RegionIdentifier = "SearchingRegion"
        }
        enum Notifications {
            static let LocationAccessAllowsTracking = Notification.Name("LocationAccessAllowsTracking")
            static let LocationAccessForbidsTracking = Notification.Name("LocationAccessForbidsTracking")
            static let BeaconsFound = Notification.Name("BeaconsFound")
            
            static let UserInfoErrorKey = "error"
            static let UserInfoBeaconsKey = "beacons"
        }
    }
}

class TrackingManager: NSObject {
    static let shared = TrackingManager()
    var lastDate: Date?

    private var searchIsInProgress = false
    private var notificationCenter = NotificationCenter.default
    
    private var beaconRecords: [BeaconRecord] = []
    private var lastBeaconRecords: [Beacon]?
    private var checkedBeacons: [Beacon] = []
    private var interactionRequestBeacons: [Beacon]?
    
    private var lastBeaconsUpdate: Date?
    private var shouldDelayInterEvents = false
    private var stopHandlingBeacons = false
    private var shouldStopPostingBeaconEvents = false
    
    private var lastFetchedUserLocation: CLLocation?
    private var locationUpdateHandler: ((CLLocation) -> Void)?
    
    private override init() {
        super.init()
    }
    
    private var beaconIndetityConstraint: CLBeaconIdentityConstraint {
        return CLBeaconIdentityConstraint(uuid: UUID(uuidString: Constants.Beacons.RegionUUID)!)
    }
    
    private lazy var searchingRegion: CLBeaconRegion = {
        let region = CLBeaconRegion(beaconIdentityConstraint: beaconIndetityConstraint,
                                    identifier: Constants.Beacons.RegionIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }()
    
    private lazy var beaconsLocationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var mapLocationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    func performNoCheckDealy(delay: Int) {
        let duration = TimeInterval(delay / 1000)
        shouldStopPostingBeaconEvents = true
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.shouldStopPostingBeaconEvents = false
        }
    }
    
    func requestLocation(completion: @escaping ((CLLocation) -> Void)) {
        locationUpdateHandler = completion
        mapLocationManager.requestLocation()
    }
    
    func handleLocationServiceAuthorization() {
        if (CLLocationManager.locationServicesEnabled()) {
            if #available(iOS 14.0, *) {
                switch (beaconsLocationManager.authorizationStatus) {
                case .notDetermined:
                    beaconsLocationManager.requestAlwaysAuthorization()
                    let errorUserInfo = [Constants.Notifications.UserInfoErrorKey : TrackingError.locationNotDetermined]
                    notificationCenter.post(Notification(name: Constants.Notifications.LocationAccessForbidsTracking, object: self, userInfo: errorUserInfo))
                case .authorizedAlways, .authorizedWhenInUse:
                    notificationCenter.post(Notification(name: Constants.Notifications.LocationAccessAllowsTracking, object: self, userInfo: nil))
                default:
                    let errorUserInfo = [Constants.Notifications.UserInfoErrorKey : TrackingError.locationEnabledInUseOnly]
                    notificationCenter.post(Notification(name: Constants.Notifications.LocationAccessForbidsTracking, object: self, userInfo: errorUserInfo))
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func startListentingForBeaconsInProximity() {
        beaconsLocationManager.startMonitoring(for: searchingRegion)
    }
    
    func stopListeningForBeacons() {
        beaconsLocationManager.stopMonitoring(for: searchingRegion)
        beaconsLocationManager.stopRangingBeacons(satisfying: beaconIndetityConstraint)
    }
    
    func userActionTriggered(_ beacons: [Beacon], nextActionDelay: Int?) {
    }
    
    func stopDelayingTrackingEvents() {
        stopHandlingBeacons = false
    }
}

//MARK:- CLLocationManagerDelegate

extension TrackingManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard manager == mapLocationManager else {
            return
        }
        if let location = locations.last {
            lastFetchedUserLocation = location
            locationUpdateHandler?(location)
            mapLocationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationServiceAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard manager == beaconsLocationManager else {
            return
        }
        beaconsLocationManager.requestState(for: region)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard manager == beaconsLocationManager else {
            return
        }
        if state == CLRegionState.inside {
            print("inside")
            beaconsLocationManager.startRangingBeacons(satisfying: beaconIndetityConstraint)
        }
        else {
            print("outside")
            beaconsLocationManager.stopRangingBeacons(satisfying: beaconIndetityConstraint)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard manager == beaconsLocationManager else {
            return
        }
         print("Did Enter Beacons")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard manager == beaconsLocationManager else {
            return
        }
        print("Did Exit Beacons")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        guard manager == beaconsLocationManager,
              let lastDateTry = lastDate else {
            lastDate = Date()
            return
        }
        
        let differenceInSeconds = Int(Date().timeIntervalSince(lastDateTry))

        if beacons.count > 0, differenceInSeconds > 5 {
            print(beacons)
            var parsedBeacons = beacons.compactMap {
                Beacon(minor: $0.minor.intValue, major: $0.major.intValue, rssi: $0.rssi)
            }
            if parsedBeacons.count > 0 {
                let beaconsUserInfo = [Constants.Notifications.UserInfoBeaconsKey: parsedBeacons]
                checkedBeacons += parsedBeacons
                notificationCenter.post(Notification(name: Constants.Notifications.BeaconsFound, object: self, userInfo: beaconsUserInfo))
                lastDate = Date()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    
    private func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: Error?) {
        guard manager == beaconsLocationManager else {
            return
        }
        if let error = error {
            print(error)
        }
    }
    
}
