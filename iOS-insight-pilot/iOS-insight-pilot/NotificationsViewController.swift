//
//  NotificationsViewController.swift
//  insight
//
//  Created by Stoyan Kostov on 3.06.21.
//

import UIKit

final class NotificationsViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containmentView: UIView!
    @IBOutlet private weak var footerLabel: UILabel!
    @IBOutlet private weak var firstImageView: UIImageView!
    @IBOutlet private weak var secondImageView: UIImageView!

    var number: String?
    var travelMode: TransportType?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondaryGray
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController?.navigationBar.barTintColor = .secondaryGray
        navigationItem.title = "Нотификации"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        navigationItem.backBarButtonItem?.title = ""

        containerView.layer.cornerRadius = 30
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.white
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        containerView.layer.shadowRadius = 10.0
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .ternaryBlue

        containmentView.layer.cornerRadius = 30
        containmentView.clipsToBounds = true

        footerLabel.text = (travelMode?.bgString ?? "") + " " + (number ?? "")
        footerLabel.font = .secondaryTitleFont
        footerLabel.textColor = .textColor

        firstImageView.isHidden = true
        secondImageView.isHidden = true

        fetchData()
    }

    private func fetchData() {
        guard let string = travelMode?.string, let number = number else {
            navigationController?.popToRootViewController(animated: true)
            return
        }
        view.startLoadingIndicator()
        InsightAPI.setStopInfo(.init(travelMode: string, lineName: number),
                               for: "42",
                               completion: { [weak self] result in
                                   self?.view.stopLoadingIndicator()
                                   switch result {
                                   case .success(let response):
                                       if response.passengersWillBoard {
                                           self?.firstImageView.isHidden = false
                                       } else {
                                           self?.firstImageView.isHidden = true
                                       }
                                       if response.passengersWillDeboard {
                                           self?.secondImageView.isHidden = false
                                       } else {
                                           self?.secondImageView.isHidden = true
                                       }
                                   case .failure(let error):
                                       debugPrint(error.localizedDescription)
                                   }
                               })
    }
}
