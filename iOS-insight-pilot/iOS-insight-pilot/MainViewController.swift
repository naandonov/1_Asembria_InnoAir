//
//  MainViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

final class MainViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containmentView: UIView!
    @IBOutlet private weak var instructionsTitleLabel: UILabel!
    @IBOutlet private weak var instructionsSubtitleLabel: UILabel!

    private weak var containmentNavigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureContainment()
    }

    private func configureUI() {
        view.backgroundColor = .secondaryGray
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController?.navigationBar.barTintColor = .secondaryGray
        navigationItem.title = "insight"
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

        instructionsTitleLabel?.font = .primaryTitleFont
        instructionsTitleLabel?.textColor = .textColor
        instructionsTitleLabel?.text = "Инструкции за употреба"

        instructionsSubtitleLabel?.font = .secondaryTitleFont
        instructionsSubtitleLabel?.textColor = .textColor
        instructionsSubtitleLabel?.text = "Докоснете екрана два пъти с два пръста"
    }

    private func configureContainment() {
        let containmentNavigationController: UINavigationController = .containmentNavigationController
        containmentNavigationController.setNavigationBarHidden(true, animated: false)
        add(containmentNavigationController)
        self.containmentNavigationController = containmentNavigationController
    }
}

// MARK: - Child View Controllers

private extension MainViewController {
    func add(_ child: UIViewController) {
        addChild(child)

        containmentView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: containmentView.leadingAnchor, constant: 0.0),
            child.view.trailingAnchor.constraint(equalTo: containmentView.trailingAnchor, constant: 0.0),
            child.view.topAnchor.constraint(equalTo: containmentView.topAnchor, constant: 0.0),
            child.view.bottomAnchor.constraint(equalTo: containmentView.bottomAnchor, constant: 0.0)
        ])
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        containmentView.subviews.forEach { $0.removeFromSuperview() }
        removeFromParent()
    }
}

// MARK: - Utils (private)

private extension MainViewController {

}
