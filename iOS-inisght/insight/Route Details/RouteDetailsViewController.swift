//
//  RouteDetailsViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

class RouteDetailsViewController: UIViewController {

    @IBOutlet private weak var infoContainerView: UIView!
    @IBOutlet private weak var destinationLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var transportLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    var destionation: String?
    private var routeDescriptor: RouteDescriptor? {
        didSet {
            tableView.reloadData()
            populateData()
        }
    }
    var backgroundView: UIView = UIView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        
        BeaconsHandler.shared.startListening()
        BeaconsHandler.shared.delegate = self
        
        TrackingManager.shared.requestLocation { [weak self] location in
            GoogleAPI.getGeocode(for: self?.destionation ?? "") { result in
                if case let .success(geocode) = result {
                    if let endLocation = geocode.results.first?.location {
                        SofiaTrafficAPI.getDirection(from: Geocode.Location(lat: location.coordinate.latitude, lng: location.coordinate.longitude), to: endLocation) { result in
                            if case let .success(direction) = result {
                                self?.routeDescriptor = RouteDescriptor(direction: direction)
                                if let firstStop = self?.routeDescriptor?.stops.first,
                                   let stopId = firstStop.stopId {
                                    StorageManager.shared.setItem(UpcomingStop(stopId: stopId))
                                }
                                self?.backgroundView.isHidden = true                                
                                StorageManager.shared.setItem(ActiveRoute(destination: self?.destionation ?? "",
                                                                          stopIds: self?.routeDescriptor?.stops.compactMap({$0.stopId}) ?? [],
                                                                          stopNames: self?.routeDescriptor?.stops.compactMap({$0.name}) ?? [],
                                                                          travelMode: self?.routeDescriptor?.travelMode ?? "" ,
                                                                          lineName: self?.routeDescriptor?.lineName ?? ""))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
    }
    
    private func configureUI() {
        infoContainerView.layer.cornerRadius = 20
        infoContainerView.layer.masksToBounds = true;
        infoContainerView.backgroundColor = UIColor.white
        infoContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        infoContainerView.layer.shadowOpacity = 0.7
        infoContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        infoContainerView.layer.shadowRadius = 10.0
        infoContainerView.layer.masksToBounds = false
        infoContainerView.backgroundColor = .primaryBlue
        
        destinationLabel.font = .primaryTitleFont
        destinationLabel.textColor = .white
        
        durationLabel.font = .secondaryTitleFont
        durationLabel.textColor = .white
        
        transportLabel.font = .secondaryTitleFont
        transportLabel.textColor = .white
        
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
        backgroundView.backgroundColor = .white
    }
    
    private func populateData() {
        guard let routeDescriptor = routeDescriptor else {
            return
        }
        destinationLabel.text = destionation
        durationLabel.text = routeDescriptor.duration
        transportLabel.text = routeDescriptor.fullTransitName
        
        let content = "Началната спирка по вашия маршрут се намира на " + routeDescriptor.startContent +
            ". Вземете " + routeDescriptor.fullTransitName + ". Пътуването ще продължи " + routeDescriptor.duration
        SpeechService.shared.speak(text: content,
                                   completion: { data in
                                    guard let data = data else {
                                        return
                                    }
                                    SpeechService.shared.play(data)
                                   })
    }
}

extension RouteDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let routeDescriptor = routeDescriptor else {
            return 0
        }
        return routeDescriptor.stops.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as? StopTableViewCell,
              let routeDescriptor = routeDescriptor,
              let upcomingStop: UpcomingStop = StorageManager.shared.getItem() else {
            return UITableViewCell()
        }
        let activeUpcomingStop = routeDescriptor.firstIndexOfStop(upcomingStop.stopId)
        
        if indexPath.row == 0 {
            cell.configure(.disabled(location: .top), name: routeDescriptor.startContent, progress: .passed)
        } else if indexPath.row == 1 {
            if activeUpcomingStop == 0 {
                cell.configure(.activeStart(location: .middle), name: routeDescriptor.stops[0].name, progress: .current)
            } else {
                cell.configure(.inactiveStart(location: .middle), name: routeDescriptor.stops[0].name, progress: .passed)
            }
        } else if indexPath.row == routeDescriptor.stops.count {
            if activeUpcomingStop == routeDescriptor.stops.count - 1 {
                cell.configure(.activeEnd(location: .middle), name: routeDescriptor.stops[routeDescriptor.stops.count - 1].name, progress: .current)
            } else {
                cell.configure(.inactiveEnd(location: .middle), name: routeDescriptor.stops[routeDescriptor.stops.count - 1].name, progress: .upcoming)
            }
        } else if indexPath.row == routeDescriptor.stops.count + 1 {
            cell.configure(.disabled(location: .bottom), name: routeDescriptor.endContent, progress: .passed)
        } else {
            if activeUpcomingStop == indexPath.row - 1 {
                cell.configure(.active(location: .middle), name: routeDescriptor.stops[indexPath.row - 1].name, progress: .current)
            } else if activeUpcomingStop < indexPath.row - 1 {
                cell.configure(.inactive(location: .middle), name: routeDescriptor.stops[indexPath.row - 1].name, progress: .upcoming)
            } else {
                cell.configure(.inactive(location: .middle), name: routeDescriptor.stops[indexPath.row - 1].name, progress: .passed)
            }
        }
        
        return cell
    }
}

extension RouteDetailsViewController: BeaconsHandlerDelegate {
    func didChangeStop() {
        tableView.reloadData()
    }
    
    func didReachFinalStop() {
        guard let routeDescriptor = routeDescriptor else {
            return
        }
        let viewController = UIViewController.successViewController
        viewController.content = "До вашата дестинация остава придвижване от " + routeDescriptor.endContent
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
