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

        footerLabel.text = travelMode?.bgString
        footerLabel.font = .secondaryTitleFont
        footerLabel.textColor = .textColor

        fetchData()
    }

    private func fetchData() {
        InsightAPI.setStopInfo(.init(travelMode: travelMode?.string, lineName: number!),
                               for: "42",
                               completion: { result in
                                print(result)
                               })
    }
}
