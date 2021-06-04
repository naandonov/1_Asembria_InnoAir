//
//  MainViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

enum TransportType: Int {
    case bus = 0
    case trolls
    case tram
    case subway

    var string: String {
        switch self {
        case .bus:
            return "bus"
        case .trolls:
            return "trolley"
        case .tram:
            return "tram"
        case .subway:
            return "subway"
        }
    }

    var bgString: String {
        switch self {
        case .bus:
            return "Автобус"
        case .trolls:
            return "Тролей"
        case .tram:
            return "Трамвай"
        case .subway:
            return "Метро"
        }
    }
}

final class MainViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containmentView: UIView!
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    private weak var containmentNavigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureHideKeyboardGesture()
    }

    private func configureHideKeyboardGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(gesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    private func configureUI() {
        view.backgroundColor = .secondaryGray
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController?.navigationBar.barTintColor = .secondaryGray
        navigationItem.title = "insight Pilot"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]

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

        titleLabel.font = .primaryTitleFont
        titleLabel.textColor = .textColor

        numberLabel.font = .secondaryTitleFont
        numberLabel.textColor = .darkText

        typeLabel.font = .secondaryTitleFont
        typeLabel.textColor = .darkText

        button.backgroundColor = .primaryBlue
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let notificationViewController = segue.destination as! NotificationsViewController
        notificationViewController.number = textField.text
        notificationViewController.travelMode = TransportType(rawValue: segmentControl.selectedSegmentIndex)?.string
    }

//    private func configureContainment() {
//        let containmentNavigationController: UINavigationController = .containmentNavigationController
//        containmentNavigationController.setNavigationBarHidden(true, animated: false)
//        add(containmentNavigationController)
//        self.containmentNavigationController = containmentNavigationController
//    }
}

//// MARK: - Child View Controllers
//
//private extension MainViewController {
//    func add(_ child: UIViewController) {
//        addChild(child)
//
//        containmentView.addSubview(child.view)
//        child.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            child.view.leadingAnchor.constraint(equalTo: containmentView.leadingAnchor, constant: 0.0),
//            child.view.trailingAnchor.constraint(equalTo: containmentView.trailingAnchor, constant: 0.0),
//            child.view.topAnchor.constraint(equalTo: containmentView.topAnchor, constant: 0.0),
//            child.view.bottomAnchor.constraint(equalTo: containmentView.bottomAnchor, constant: 0.0)
//        ])
//        child.didMove(toParent: self)
//    }
//
//    func remove() {
//        willMove(toParent: nil)
//        containmentView.subviews.forEach { $0.removeFromSuperview() }
//        removeFromParent()
//    }
//}

// MARK: - Utils (private)

private extension MainViewController {

}
