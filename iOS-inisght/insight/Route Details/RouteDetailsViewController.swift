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
    
    var destionation: String? = "Ветеринарна клиника орион"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        
        TrackingManager.shared.requestLocation { [weak self] location in
            GoogleAPI.getGeocode(for: self?.destionation ?? "") { result in
                if case let .success(geocode) = result {
                    if let endLocation = geocode.results.first?.location {
                        SofiaTrafficAPI.getDirection(from: Geocode.Location(lat: location.coordinate.latitude, lng: location.coordinate.longitude), to: endLocation) { result in
                            if case let .success(direction) = result {
                                print(direction)
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
    }
}

extension RouteDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as? StopTableViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configure(.disabled(location: .top), name: "Stop name title", progress: .passed)
        } else if indexPath.row == 1 {
            cell.configure(.activeStart(location: .middle), name: "Stop name title", progress: .current)
        } else if indexPath.row == 7 {
            cell.configure(.inactiveEnd(location: .middle), name: "Stop name title", progress: .upcoming)
        } else if indexPath.row == 8 {
            cell.configure(.disabled(location: .bottom), name: "Stop name title", progress: .passed)
        } else {
            cell.configure(.inactive(location: .middle), name: "Stop name title", progress: .upcoming)
        }
        
        return cell
    }
}
